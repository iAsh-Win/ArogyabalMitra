import pandas as pd
import requests
import re
import time
from difflib import get_close_matches
import os
from django.conf import settings

API_URL = "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2"
HF_API_KEY = "***************************"
headers = {"Authorization": f"Bearer {HF_API_KEY}"}

csv_file_path = os.path.join(settings.BASE_DIR, 'api', 'data', 'mycsv.csv')

# Load the CSV
try:
    food_df = pd.read_csv(csv_file_path)
except FileNotFoundError as e:
    raise Exception(f"CSV file not found: {e}")

# Create food list
food_list = [{
    "english": row['Food Item (English)'],
    "hindi": row['Food Item (Hindi)'],
    "tags": ', '.join(
        [tag for tag, present in zip(
            ['protein-rich', 'vitamin A-rich', 'iron-rich', 'energy-rich'],
            [row['Protein'] == 'Yes', row['Vitamin A'] == 'Yes', row['Iron'] == 'Yes', row['Carbohydrates'] == 'Yes']
        ) if present]
    )
} for _, row in food_df.iterrows()]

# Supplement Mapping
supplement_mapping = {
    "Protein": ["Protein powder", "Balbhog", "Poshan Sachet (MNP)"],
    "Iron": ["Iron-Folic Acid syrup", "DFS Namak", "Poshan Sachet (MNP)"],
    "Vitamin A": ["Vitamin A syrup", "Bal Amrit / Bal Shakti", "Poshan Sachet (MNP)"],
    "Carbohydrates": ["Balbhog"]
}

def create_food_prompt(malnutrition_data):
    z_scores = malnutrition_data.get('Z-Score Analysis', {}).get('Z Scores', {})
    deficiencies = malnutrition_data.get('Nutrient Deficiencies', {})

    foods = ', '.join([f"{f['english']} ({f['tags']})" for f in food_list])

    prompt = f"""
### Instruction:
You are a rural Indian nutritionist. Based on the following data, suggest 9 affordable, locally available foods to support recovery and reduce malnutrition.
ONLY pick from the foods below. Output only food names as bullet points. DO NOT explain or describe anything.

### Child's Data:
WAZ: {z_scores.get('waz', 'N/A')}
HAZ: {z_scores.get('haz', 'N/A')}
WHZ: {z_scores.get('whz', 'N/A')}
MUAC: {z_scores.get('muac', 'N/A')}
Protein Deficiency: {'Yes' if deficiencies.get('Protein') else 'No'}
Iron Deficiency: {'Yes' if deficiencies.get('Iron') else 'No'}
Vitamin A Deficiency: {'Yes' if deficiencies.get('Vitamin A') else 'No'}
Carbohydrate Deficiency: {'Yes' if deficiencies.get('Carbohydrates') else 'No'}

### Available Foods:
{foods}

### Response:
"""
    return prompt

def get_hindi_name(item_text):
    item_text_clean = re.sub(r"[\-•]", "", item_text).strip()
    food_names = [f['english'] for f in food_list]
    match = get_close_matches(item_text_clean, food_names, n=1, cutoff=0.6)
    if match:
        for f in food_list:
            if f['english'] == match[0]:
                return f['hindi']
    return 'हिंदी नाम उपलब्ध नहीं'

def call_api_with_retry(prompt, retries=3):
    for attempt in range(retries):
        try:
            response = requests.post(
                API_URL,
                headers=headers,
                json={"inputs": prompt, "parameters": {"max_new_tokens": 150}},
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2)
            else:
                raise Exception(f"API call failed after {retries} attempts: {e}")

def get_food_suggestions(malnutrition_data):
    try:
        prompt = create_food_prompt(malnutrition_data)
        output = call_api_with_retry(prompt)
        if output and isinstance(output, list) and "generated_text" in output[0]:
            bullets = re.findall(r"^- .*", output[0]["generated_text"], re.MULTILINE)[:9]
            return [{
                "item": re.sub(r"^- ", "", item).strip(),
                "hindi": get_hindi_name(re.sub(r"^- ", "", item).strip())
            } for item in bullets]
        return fallback_food_recommendation()
    except Exception as e:
        raise Exception(f"Error in fetching food suggestions: {e}")

def get_dynamic_supplements(malnutrition_data):
    try:
        deficiencies = malnutrition_data.get('Nutrient Deficiencies', {})
        recommended = set()
        for nutrient, has_deficiency in deficiencies.items():
            if has_deficiency and nutrient in supplement_mapping:
                recommended.update(supplement_mapping[nutrient])
        return list(recommended)
    except Exception as e:
        raise Exception(f"Error in fetching supplements: {e}")

def fallback_food_recommendation():
    return [{
        "item": f['english'],
        "hindi": f['hindi']
    } for f in food_list[:9]]

def get_full_recommendation(malnutrition_data):
    try:
        food_recs = get_food_suggestions(malnutrition_data)
        supplements = get_dynamic_supplements(malnutrition_data)
        return {
            "foods": food_recs,
            "supplements": supplements if supplements else None
        }
    except Exception as e:
        return {"error": str(e)}

# Modular Function for External Use
def generate_recommendation(malnutrition_data):
    try:
        result = get_full_recommendation(malnutrition_data)
        return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}


