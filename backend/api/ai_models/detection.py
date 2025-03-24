import pandas as pd
import math
import numpy as np
import joblib
import traceback


def analyze_child_nutrition(
    csv_file,
    z_scores_file,
    food_intake,
    child_data,
    model_path="malnutrition_rf_model.pkl",
    encoder_path="label_encoder.pkl",
    columns_path="trained_columns.pkl",
):
    """
    Main function to analyze child nutrition status by encapsulating all other functions.

    Parameters:
    csv_file (str): Path to the food nutrition CSV file
    z_scores_file (str): Path to the Z-scores data CSV file
    food_intake (dict): Dictionary of food items and their consumption weight in grams
    child_data (dict): Dictionary containing child's data (Age, Gender, Weight, Height, MUAC, etc.)
    model_path (str): Path to the saved ML model
    encoder_path (str): Path to the saved label encoder
    columns_path (str): Path to the saved trained columns

    Returns:
    dict: Result containing status ('success' or 'error') and data or error message
    """
    try:
        # Load saved model, label encoder, and trained column names
        rf_status = joblib.load(model_path)
        le_status = joblib.load(encoder_path)
        trained_columns = joblib.load(columns_path)

        # Analyze nutrition intake and deficiencies
        nutrient_intake, nutrient_deficiencies = analyze_nutrition(
            csv_file, food_intake, child_data
        )

        # Assess child malnutrition status using z-scores
        malnutrition_status, z_scores = assess_child_nutrition(
            z_scores_file,
            child_data["Gender"],
            child_data["Age"],
            child_data["Weight"],
            child_data["Height"],
            child_data["MUAC"],
        )

        # Prepare data for model prediction
        user_data = {
            "Age (Months)": child_data["Age"],
            "Gender": child_data["Gender"],
            "Height (cm)": child_data["Height"],
            "Weight (kg)": child_data["Weight"],
            "MUAC (cm)": child_data["MUAC"],
            "WAZ": z_scores["waz"],
            "HAZ": z_scores["haz"],
            "WHZ": z_scores["whz"],
            "MUAC Z": z_scores["muac"],
            "Meal Frequency": child_data["Meal_Frequency"],
            "Dietary Diversity Score": child_data["Dietary_Diversity_Score"],
            "Protein Intake (g)": nutrient_intake["Protein"]["Current Intake (g)"],
            "Carbs Intake (g)": nutrient_intake["Carbohydrates"]["Current Intake (g)"],
            "Vitamin A (µg)": nutrient_intake["Vitamin A"]["Current Intake (µg)"],
            "Iron (mg)": nutrient_intake["Iron"]["Current Intake (mg)"],
            "Vitamin A Deficiency": str(nutrient_deficiencies["Vitamin A"]),
            "Iron Deficiency": str(nutrient_deficiencies["Iron"]),
            "Protein Deficiency": str(nutrient_deficiencies["Protein"]),
            "Carbohydrate Deficiency": str(nutrient_deficiencies["Carbohydrates"]),
            "Clean Water": str(child_data["Clean_Water"]),
            "Illness": ", ".join(child_data["Illness"]),
        }

        # Preprocess user input for model prediction
        processed_data = preprocess_input(user_data, trained_columns)

        # Predict Malnutrition Status
        status_pred = rf_status.predict(processed_data)
        status_pred_label = le_status.inverse_transform(status_pred)[0]

        # Predict Recommended Nutrients
        nutrients_pred = recommend_nutrients(processed_data.iloc[0])

        # Prepare the final result
        result = {
            "status": "success",
            "data": {
                "Current Intake": nutrient_intake,
                "Nutrient Deficiencies": nutrient_deficiencies,
                "Z-Score Analysis": {
                    "Malnutrition Status": malnutrition_status,
                    "Z Scores": z_scores,
                },
                "Model Prediction": {
                    "Predicted Status": status_pred_label,
                    "Recommended Nutrients": nutrients_pred,
                },
            },
        }

        return result

    except Exception as e:
        # Return error status with traceback info for debugging
        error_msg = str(e)
        error_traceback = traceback.format_exc()
        return {"status": "error", "message": error_msg, "details": error_traceback}


# Function to preprocess input data
def preprocess_input(data, trained_columns):
    """
    Preprocess user input to match training format.
    :param data: Dictionary containing input values
    :param trained_columns: List of feature columns used in training
    :return: Processed DataFrame
    """
    df = pd.DataFrame([data])  # Convert dictionary to DataFrame

    # 1. **Standardize Column Names (Strip Spaces)**
    df.columns = df.columns.str.strip()

    # 2. **Convert Boolean Columns to Numeric (0/1)**
    boolean_cols = [
        "Vitamin A Deficiency",
        "Iron Deficiency",
        "Protein Deficiency",
        "Carbohydrate Deficiency",
        "Clean Water",
    ]
    for col in boolean_cols:
        df[col] = df[col].map({"True": 1, "False": 0}).astype(int)

    # 3. **Encode 'Gender' Column (M -> 0, F -> 1)**
    df["Gender"] = df["Gender"].map({"M": 0, "F": 1})

    # 4. **Process 'Illness' Column (Multi-Label Encoding)**
    if "Illness" in df.columns:
        df["Illness"] = df["Illness"].apply(
            lambda x: ", ".join([i.strip() for i in x.split(",")])
        )
        illness_dummies = df["Illness"].str.get_dummies(sep=", ")
        df = pd.concat([df, illness_dummies], axis=1)
        df.drop(columns=["Illness"], inplace=True)

    # 5. **Ensure All Training Columns Exist and Are in the Correct Order**
    df = df.reindex(columns=trained_columns, fill_value=0)

    return df


# Function to recommend nutrients based on deficiencies
def recommend_nutrients(row):
    recommendations = []
    if row["Vitamin A Deficiency"] == 1:
        recommendations.append("Vitamin A")
    if row["Iron Deficiency"] == 1:
        recommendations.append("Iron")
    if row["Protein Deficiency"] == 1:
        recommendations.append("Protein")
    if row["Carbohydrate Deficiency"] == 1:
        recommendations.append("Carbohydrates")
    return recommendations if recommendations else ["Balanced Diet"]


def analyze_nutrition(csv_file, food_intake, child_data):
    df = pd.read_csv(csv_file)

    # Determine the highest nutrient in each food item
    df["Nutrient Type"] = df[["Protein", "Vitamin A", "Iron", "Carbohydrates"]].idxmax(
        axis=1
    )

    # Pivot the table to group values by nutrient type
    pivot_df = df.pivot(
        index="Food Item (English)",
        columns="Nutrient Type",
        values="Nutrient per 100g (g)",
    )
    pivot_df.reset_index(inplace=True)
    pivot_df.rename(columns={"Food Item (English)": "Food Item"}, inplace=True)
    pivot_df.fillna(0, inplace=True)

    # Convert nutrient values to proper units
    if "Iron" in pivot_df.columns:
        pivot_df["Iron"] *= 1000  # Convert to mg
    if "Vitamin A" in pivot_df.columns:
        pivot_df["Vitamin A"] *= 1000000  # Convert to µg

    # Calculate total nutrient intake from food consumption
    total_nutrients = {"Protein": 0, "Iron": 0, "Vitamin A": 0, "Carbohydrates": 0}
    for food, weight in food_intake.items():
        food_row = pivot_df[pivot_df["Food Item"].str.lower() == food.lower()]
        if not food_row.empty:
            total_nutrients["Protein"] += (food_row["Protein"].values[0] * weight) / 100
            total_nutrients["Iron"] += (food_row["Iron"].values[0] * weight) / 100
            total_nutrients["Vitamin A"] += (
                food_row["Vitamin A"].values[0] * weight
            ) / 100
            total_nutrients["Carbohydrates"] += (
                food_row["Carbohydrates"].values[0] * weight
            ) / 100

    # Define recommended daily intake
    age_years = child_data["Age"] / 12
    weight = child_data["Weight"]
    gender = child_data["Gender"].lower()

    protein_recommendation = 1.1 * weight if age_years < 4 else 0.95 * weight
    iron_recommendation = (
        11
        if age_years < 1
        else (
            7
            if age_years < 4
            else (
                10
                if age_years < 9
                else 8 if age_years < 14 else 11 if gender == "m" else 15
            )
        )
    )
    vitamin_a_recommendation = (
        500
        if age_years < 1
        else (
            300
            if age_years < 4
            else (
                400
                if age_years < 9
                else 600 if age_years < 14 else 900 if gender == "m" else 700
            )
        )
    )
    carbohydrate_recommendation = 130

    # Organize the intake results
    nutrient_intake = {
        "Protein": {
            "Current Intake (g)": round(total_nutrients["Protein"], 2),
            "Recommended (g)": round(protein_recommendation, 2),
        },
        "Iron": {
            "Current Intake (mg)": round(total_nutrients["Iron"], 2),
            "Recommended (mg)": iron_recommendation,
        },
        "Vitamin A": {
            "Current Intake (µg)": round(total_nutrients["Vitamin A"], 2),
            "Recommended (µg)": vitamin_a_recommendation,
        },
        "Carbohydrates": {
            "Current Intake (g)": round(total_nutrients["Carbohydrates"], 2),
            "Recommended (g)": carbohydrate_recommendation,
        },
    }

    # Identify deficiencies
    nutrient_deficiencies = {
        "Protein": total_nutrients["Protein"] < protein_recommendation,
        "Iron": total_nutrients["Iron"] < iron_recommendation,
        "Vitamin A": total_nutrients["Vitamin A"] < vitamin_a_recommendation,
        "Carbohydrates": total_nutrients["Carbohydrates"] < carbohydrate_recommendation,
    }

    return nutrient_intake, nutrient_deficiencies


def assess_child_nutrition(
    file_path, gender, age_months, weight_kg, height_cm, muac_cm
):
    data = pd.read_csv(file_path)

    # Correct gender formatting
    gender = "Girl" if gender == "F" else "Boy"

    def calculate_z_score(x, l, m, s):
        if l == 0:
            return math.log(x / m) / s
        else:
            return (((x / m) ** l) - 1) / (l * s)

    def classify(z_score, indicator):
        if z_score > 2:
            return "Overweight" if indicator in ["WHZ", "WAZ"] else "Tall-for-age"
        elif -2 <= z_score <= 2:
            return "Normal"
        elif -3 <= z_score < -2:
            return {
                "WAZ": "Moderately underweight",
                "HAZ": "Moderate stunting",
                "WHZ": "Moderate wasting",
                "MUAC": "MUAC Moderate wasting",
            }.get(indicator, "Moderate malnutrition")
        elif z_score < -3:
            return {
                "WAZ": "Severely underweight",
                "HAZ": "Severe stunting",
                "WHZ": "Severe wasting",
                "MUAC": "MUAC Severe wasting",
            }.get(indicator, "Severe malnutrition")
        return "Unknown"

    gender = gender.capitalize()
    indicators = ["waz", "haz", "whz", "muac"]
    z_scores = {}
    statuses = {}

    for indicator in indicators:
        if indicator == "whz":
            row = data[
                (data["Gender"] == gender)
                & (data["Data"] == indicator)
                & (data["Height(cm)"] == height_cm)
            ]
        else:
            row = data[
                (data["Gender"] == gender)
                & (data["Data"] == indicator)
                & (data["Month"] == age_months)
            ]

        if row.empty:
            continue

        z_scores[indicator] = round(
            calculate_z_score(
                (
                    weight_kg
                    if indicator in ["waz", "whz"]
                    else height_cm if indicator == "haz" else muac_cm
                ),
                row.iloc[0]["L"],
                row.iloc[0]["M"],
                row.iloc[0]["S"],
            ),
            2,
        )
        statuses[indicator] = classify(z_scores[indicator], indicator.upper())

    severe_conditions = [status for status in statuses.values() if "Severe" in status]
    moderate_conditions = [
        status for status in statuses.values() if "Moderate" in status
    ]

    if severe_conditions:
        overall_status = ", ".join(severe_conditions)
        malnutrition_status = "Severe Malnutrition"
    elif moderate_conditions:
        overall_status = ", ".join(moderate_conditions)
        malnutrition_status = "Moderate Malnutrition"
    else:
        overall_status = "Normal"
        malnutrition_status = "No Malnutrition"

    return malnutrition_status, z_scores


# # Example usage
# if __name__ == "__main__":
#     food_intake = {"Milk (cow's)": 300, "Eggs (boiled)": 50, "Spinach": 100, "Poha (flattened rice)":298}
#     child_data = {
#         "Age": 48,  # in months
#         "Gender": "M",
#         "Weight": 20,  # in kg
#         "Height": 100,  # in cm
#         "MUAC": 15,  # Mid-upper arm circumference in cm
#         "Meal_Frequency": 3,  # Example value, number of meals per day
#         "Dietary_Diversity_Score": 4,  # Example score for dietary variety
#         "Clean_Water": True,  # Access to clean drinking water (True/False)
#         "Illness": ["Diarrhea", "Fever"]  # Example array of illnesses
#     }

#     result = analyze_child_nutrition("mycsv.csv", "Data_new.csv", food_intake, child_data,model_path=model_path, encoder_path=encoder_path, columns_path=columns_path)

#     return {"result": result}
