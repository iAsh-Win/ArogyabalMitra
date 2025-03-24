from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.http import JsonResponse
from ..models import Child, Supplement  # Import the Supplement model
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime
from ..ai_models.detection import analyze_child_nutrition  # Import the function
import os
from django.conf import settings
import json  # Import json module for serialization
import numpy as np  # Import numpy for type checking
from ..ai_models.suggestions import generate_recommendation  # Import the function

model_path = os.path.join(settings.BASE_DIR, 'api', 'ai_models', 'malnutrition_rf_model.pkl')
encoder_path = os.path.join(settings.BASE_DIR, 'api', 'ai_models', 'label_encoder.pkl')
columns_path = os.path.join(settings.BASE_DIR, 'api', 'ai_models', 'trained_columns.pkl')
csv_file_path = os.path.join(settings.BASE_DIR, 'api', 'data', 'mycsv.csv')
z_scores_file = os.path.join(settings.BASE_DIR, 'api', 'data', 'Data_new.csv')


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def check_malnutrition(request, child_id):
    try:
        child = Child.objects.get(id=child_id)
        if child is None:
            return JsonResponse({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
        
        # Extract food intake and other child data from the request
        food_intake = request.data.get("food_intake", {})
        child_data_request = request.data.get("child_data", {})

        # Calculate child's age in months from birth_date
        if child.birth_date:
            today = datetime.today()
            age_in_months = (today.year - child.birth_date.year) * 12 + today.month - child.birth_date.month
        else:
            age_in_months = None

        # Update child_data with calculated age and other request data
        child_data = {
            "Age": age_in_months,  # in months
            "Gender": "M" if child.gender.lower() == "male" else "F",  # Convert gender to M/F
            "Weight": child_data_request.get("Weight"),  # in kg
            "Height": child_data_request.get("Height"),  # in cm
            "MUAC": child_data_request.get("MUAC"),  # Mid-upper arm circumference in cm
            "Meal_Frequency": child_data_request.get("Meal_Frequency"),  # Number of meals per day
            "Dietary_Diversity_Score": child_data_request.get("Dietary_Diversity_Score"),  # Dietary variety score
            "Clean_Water": child_data_request.get("Clean_Water"),  # Access to clean drinking water (True/False)
            "Illness": child_data_request.get("Illness", [])  # Array of illnesses
        }
        
        # Call the analyze_child_nutrition function
        result = analyze_child_nutrition(
            csv_file=csv_file_path,
            z_scores_file=z_scores_file,
            food_intake=food_intake,
            child_data=child_data,
            model_path=model_path,
            encoder_path=encoder_path,
            columns_path=columns_path
        )

        # Check if the result indicates success
        if result["status"] == "success":
            # Convert all numpy types and bools in the result to JSON-compatible types
            def convert_types(obj):
                if isinstance(obj, dict):
                    return {k: convert_types(v) for k, v in obj.items()}
                elif isinstance(obj, list):
                    return [convert_types(i) for i in obj]
                elif isinstance(obj, (np.float64, np.float32)):
                    return float(obj)  # Convert numpy float to Python float
                elif isinstance(obj, (np.int64, np.int32)):
                    return int(obj)  # Convert numpy int to Python int
                elif isinstance(obj, (np.bool_, bool)):
                    return bool(obj)  # Convert numpy bool to Python bool
                else:
                    return obj

            result = convert_types(result)

            # Add additional fields to the data
            data = {
                "Z-Score Analysis": {
                    "Z Scores": {
                        "waz": result["data"]["Z-Score Analysis"]["Z Scores"].get("waz", -1.2),
                        "haz": result["data"]["Z-Score Analysis"]["Z Scores"].get("haz", -1.0),
                        "whz": result["data"]["Z-Score Analysis"]["Z Scores"].get("whz", -1.3),
                        "muac": result["data"]["Z-Score Analysis"]["Z Scores"].get("muac", 12.2)
                    }
                },
                "Nutrient Deficiencies": {
                    "Protein": result["data"]["Nutrient Deficiencies"].get("Protein", True),
                    "Iron": result["data"]["Nutrient Deficiencies"].get("Iron", True),
                    "Vitamin A": result["data"]["Nutrient Deficiencies"].get("Vitamin A", True),
                    "Carbohydrates": result["data"]["Nutrient Deficiencies"].get("Carbohydrates", True)
                }
            }
           
            # Call the generate_recommendation function
            recommendations = generate_recommendation(data)


            # Fetch supplement IDs from the database
            supplements_with_ids = []
            if recommendations and "supplements" in recommendations["data"]:
                for supplement_name in recommendations["data"]["supplements"]:
                    try:
                        supplement = Supplement.objects.get(name=supplement_name)
                        supplements_with_ids.append({
                            "name": supplement.name,
                            "id": str(supplement.id)
                        })
                    except Supplement.DoesNotExist:
                        supplements_with_ids.append({
                            "name": supplement_name,
                            "id": None  # If supplement not found, return None for ID
                        })
            else:
                # Handle the case where "supplements" key is missing
                supplements_with_ids = []

            # Include recommendations and supplement IDs in the response
            result["data"]["Recommendations"] = {
                "foods": recommendations["data"].get("foods", []) if "data" in recommendations else [],
                "supplements": supplements_with_ids
            }


            return JsonResponse(result, status=status.HTTP_200_OK)

        # If the result indicates an error, raise an exception with the error message
        raise Exception(result["message"])

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
