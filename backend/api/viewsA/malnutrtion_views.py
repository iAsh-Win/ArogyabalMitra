from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.http import JsonResponse
from ..models import (
    Child,
    Supplement,
    MalnutritionRecord,
    SupplementDistribution,
)  # Import the Supplement and MalnutritionRecord models
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime
from ..ai_models.detection import analyze_child_nutrition  # Import the function
import os
from django.conf import settings
import json  # Import json module for serialization
import numpy as np  # Import numpy for type checking
from ..ai_models.suggestions import generate_recommendation  # Import the function
import uuid  # Import uuid module for generating UUIDs

model_path = os.path.join(
    settings.BASE_DIR, "api", "ai_models", "malnutrition_rf_model.pkl"
)
encoder_path = os.path.join(settings.BASE_DIR, "api", "ai_models", "label_encoder.pkl")
columns_path = os.path.join(
    settings.BASE_DIR, "api", "ai_models", "trained_columns.pkl"
)
csv_file_path = os.path.join(settings.BASE_DIR, "api", "data", "mycsv.csv")
z_scores_file = os.path.join(settings.BASE_DIR, "api", "data", "Data_new.csv")


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def check_malnutrition(request, child_id):
    try:
        child = Child.objects.get(id=child_id)

        if child is None:
            return JsonResponse(
                {"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND
            )

        # Extract food intake and other child data from the request
        food_intake = request.data.get("food_intake", {})
        child_data_request = request.data.get("child_data", {})

        # Validate mandatory fields
        mandatory_fields = [
            "Weight",
            "Height",
            "MUAC",
            "Meal_Frequency",
            "Dietary_Diversity_Score",
            "Clean_Water",
        ]
        missing_fields = [
            field for field in mandatory_fields if field not in child_data_request
        ]
        if missing_fields:
            return JsonResponse(
                {"message": f"Missing mandatory fields: {', '.join(missing_fields)}"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Calculate child's age in months from birth_date
        if child.birth_date:
            today = datetime.today()
            age_in_months = (
                (today.year - child.birth_date.year) * 12
                + today.month
                - child.birth_date.month
            )
        else:
            age_in_months = None

        # Update child_data with calculated age and other request data
        child_data = {
            "Age": age_in_months,  # in months
            "Gender": (
                "M" if child.gender.lower() == "male" else "F"
            ),  # Convert gender to M/F
            "Weight": child_data_request.get("Weight"),  # in kg
            "Height": child_data_request.get("Height"),  # in cm
            "MUAC": child_data_request.get("MUAC"),  # Mid-upper arm circumference in cm
            "Meal_Frequency": child_data_request.get(
                "Meal_Frequency"
            ),  # Number of meals per day
            "Dietary_Diversity_Score": child_data_request.get(
                "Dietary_Diversity_Score"
            ),  # Dietary variety score
            "Clean_Water": child_data_request.get(
                "Clean_Water"
            ),  # Access to clean drinking water (True/False)
            "Illness": child_data_request.get("Illness", []),  # Array of illnesses
        }

        # Call the analyze_child_nutrition function
        result = analyze_child_nutrition(
            csv_file=csv_file_path,
            z_scores_file=z_scores_file,
            food_intake=food_intake,
            child_data=child_data,
            model_path=model_path,
            encoder_path=encoder_path,
            columns_path=columns_path,
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

            # Extract nutrient deficiencies
            nutrient_deficiencies = [
                nutrient
                for nutrient, is_deficient in result["data"][
                    "Nutrient Deficiencies"
                ].items()
                if is_deficient
            ]

            # Extract predicted status
            predicted_status = result["data"]["Model Prediction"].get(
                "Predicted Status"
            )

            data = {
                "Z-Score Analysis": {
                    "Z Scores": {
                        "waz": result["data"]["Z-Score Analysis"]["Z Scores"].get(
                            "waz", -1.2
                        ),
                        "haz": result["data"]["Z-Score Analysis"]["Z Scores"].get(
                            "haz", -1.0
                        ),
                        "whz": result["data"]["Z-Score Analysis"]["Z Scores"].get(
                            "whz", -1.3
                        ),
                        "muac": result["data"]["Z-Score Analysis"]["Z Scores"].get(
                            "muac", 12.2
                        ),
                    }
                },
                "Nutrient Deficiencies": {
                    "Protein": result["data"]["Nutrient Deficiencies"].get(
                        "Protein", True
                    ),
                    "Iron": result["data"]["Nutrient Deficiencies"].get("Iron", True),
                    "Vitamin A": result["data"]["Nutrient Deficiencies"].get(
                        "Vitamin A", True
                    ),
                    "Carbohydrates": result["data"]["Nutrient Deficiencies"].get(
                        "Carbohydrates", True
                    ),
                },
            }
            # Call the generate_recommendation function
            recommendations = generate_recommendation(data)
            if recommendations["status"] != "success":
                raise Exception(recommendations["message"])

            # Extract recommended foods and supplements
            recommended_foods = recommendations["data"]["foods"]
            recommended_supplements = recommendations["data"]["supplements"]

            # Fetch supplement IDs from the database
            supplements_with_ids = []
            for supplement_name in recommended_supplements:
                try:
                    supplement = Supplement.objects.get(name=supplement_name)
                    supplements_with_ids.append(
                        {"name": supplement.name, "id": str(supplement.id)}
                    )
                except Supplement.DoesNotExist:
                    supplements_with_ids.append(
                        {
                            "name": supplement_name,
                            "id": None,  # If supplement not found, return None for ID
                        }
                    )

            # Save the data into the MalnutritionRecord model
            malnutrition_record = MalnutritionRecord.objects.create(
                id=uuid.uuid4(),  # Explicitly set the UUID for the new record
                child=child,
                weight=child_data.get("Weight"),
                height=child_data.get("Height"),
                muac=child_data.get("MUAC"),
                meal_frequency=child_data.get("Meal_Frequency"),
                dietary_diversity_score=child_data.get("Dietary_Diversity_Score"),
                clean_water=child_data.get("Clean_Water"),
                illnesses=child_data.get("Illness"),
                waz=result["data"]["Z-Score Analysis"]["Z Scores"].get("waz"),
                haz=result["data"]["Z-Score Analysis"]["Z Scores"].get("haz"),
                whz=result["data"]["Z-Score Analysis"]["Z Scores"].get("whz"),
                muac_z=result["data"]["Z-Score Analysis"]["Z Scores"].get("muac"),
                predicted_status=predicted_status,
                recommended_foods=recommended_foods,
                supplements=supplements_with_ids,
                nutrient_deficiencies=nutrient_deficiencies,
            )

            # Prepare the response data from the stored record
            response_data = {
                "child": {
                    "id": str(child.id),
                    "full_name": child.full_name,
                    "age": age_in_months,
                    "gender": child.gender,
                    "birth_date": child.birth_date,
                },
                "malnutrition_record": {
                    "malnutrition_record_id": str(malnutrition_record.id),  # Include malnutrition_record_id
                    "weight": malnutrition_record.weight,
                    "height": malnutrition_record.height,
                    "muac": malnutrition_record.muac,
                    "meal_frequency": malnutrition_record.meal_frequency,
                    "dietary_diversity_score": malnutrition_record.dietary_diversity_score,
                    "clean_water": malnutrition_record.clean_water,
                    "illnesses": malnutrition_record.illnesses,
                    "z_scores": {
                        "waz": malnutrition_record.waz,
                        "haz": malnutrition_record.haz,
                        "whz": malnutrition_record.whz,
                        "muac_z": malnutrition_record.muac_z,
                    },
                    "predicted_status": malnutrition_record.predicted_status,
                    "nutrient_deficiencies": malnutrition_record.nutrient_deficiencies,
                    "recommended_foods": malnutrition_record.recommended_foods,
                    "supplements": malnutrition_record.supplements,
                    "created_at": malnutrition_record.created_at,
                },
            }

            return JsonResponse(response_data, status=status.HTTP_200_OK)

        # If the result indicates an error, raise an exception with the error message
        raise Exception(result["message"])

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_child_report(request, malnutrition_record_id):
    try:
        # Fetch the malnutrition record by its ID
        malnutrition_record = MalnutritionRecord.objects.get(id=malnutrition_record_id)


        # Fetch the associated child record
        child = malnutrition_record.child

        # Fetch supplement distribution details for the malnutrition record
        supplement_distributions = SupplementDistribution.objects.filter(
            child=child, malnutrition_record=malnutrition_record
        ).select_related("supplement")

        # Prepare supplement data with distribution details
        supplements_with_distribution = []
        for supplement in malnutrition_record.supplements:
            distributed = next(
                (
                    dist
                    for dist in supplement_distributions
                    if dist.supplement.name == supplement["name"]
                ),
                None,
            )
            supplements_with_distribution.append(
                {
                    "name": supplement["name"],
                    "id": supplement.get("id"),
                    "quantity_distributed": (
                        distributed.quantity if distributed else None
                    ),
                    "distribution_date": (
                        distributed.distribution_date if distributed else None
                    ),
                }
            )

        # Prepare the response data
        response_data = {
            "child": {
                "id": str(child.id),
                "full_name": child.full_name,
                "age": (datetime.today().year - child.birth_date.year) * 12
                + (datetime.today().month - child.birth_date.month),
                "gender": child.gender,
                "birth_date": child.birth_date,
            },
            "malnutrition_record": {
                "malnutrition_record_id": str(malnutrition_record.id),
                "weight": malnutrition_record.weight,
                "height": malnutrition_record.height,
                "muac": malnutrition_record.muac,
                "meal_frequency": malnutrition_record.meal_frequency,
                "dietary_diversity_score": malnutrition_record.dietary_diversity_score,
                "clean_water": malnutrition_record.clean_water,
                "illnesses": malnutrition_record.illnesses,
                "z_scores": {
                    "waz": malnutrition_record.waz,
                    "haz": malnutrition_record.haz,
                    "whz": malnutrition_record.whz,
                    "muac_z": malnutrition_record.muac_z,
                },
                "predicted_status": malnutrition_record.predicted_status,
                "nutrient_deficiencies": malnutrition_record.nutrient_deficiencies,
                "recommended_foods": malnutrition_record.recommended_foods,
                "supplements": supplements_with_distribution,  # Include distribution details
                "created_at": malnutrition_record.created_at,
            },
        }
        return JsonResponse(response_data, status=status.HTTP_200_OK)

    except MalnutritionRecord.DoesNotExist:
        return JsonResponse(
            {"message": "Malnutrition record not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return JsonResponse({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_child_reports(request, child_id):
    try:
        # Fetch the child record
        child = Child.objects.get(id=child_id)
        if child is None:
            return JsonResponse(
                {"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND
            )

        # Fetch all malnutrition records for the child
        malnutrition_records = MalnutritionRecord.objects.filter(child=child).order_by(
            "-created_at"
        )

        if not malnutrition_records.exists():
            return JsonResponse(
                {"message": "No malnutrition records found for this child"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Prepare the response data
        reports = []
        for record in malnutrition_records:
            reports.append({
                "malnutrition_record_id": str(record.id),  # Use the new `id` field
                "weight": record.weight,
                "height": record.height,
                "muac": record.muac,
                "meal_frequency": record.meal_frequency,
                "dietary_diversity_score": record.dietary_diversity_score,
                "clean_water": record.clean_water,
                "illnesses": record.illnesses,
                "z_scores": {
                    "waz": record.waz,
                    "haz": record.haz,
                    "whz": record.whz,
                    "muac_z": record.muac_z,
                },
                "predicted_status": record.predicted_status,
                "nutrient_deficiencies": record.nutrient_deficiencies,
                "recommended_foods": record.recommended_foods,
                "supplements": record.supplements,
                "created_at": record.created_at,
            })

        response_data = {
            "child": {
                "id": str(child.id),
                "full_name": child.full_name,
                "gender": child.gender,
                "birth_date": child.birth_date,
            },
            "reports": reports,
        }

        return JsonResponse(response_data, status=status.HTTP_200_OK)

    except Child.DoesNotExist:
        return JsonResponse(
            {"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return JsonResponse({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
