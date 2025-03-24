import csv
from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.conf import settings
import os

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_csvFoodNames(request):
    try:
        # Path to the CSV file
        csv_file_path = os.path.join(settings.BASE_DIR, 'api', 'data', 'mycsv.csv')
        
        # Read the CSV file
        food_items = []
        with open(csv_file_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                food_items.append({
                    "Food Item (English)": row["Food Item (English)"],
                    "Food Item (Hindi)": row["Food Item (Hindi)"]
                })
        
        return JsonResponse({"message": "Food items fetched successfully", "foods": food_items}, status=200)
    except FileNotFoundError:
        return JsonResponse({"error": "CSV file not found"}, status=400)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
