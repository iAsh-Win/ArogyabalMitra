from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Supplement, AnganwadiSupplement, AnganwadiUser, SupplementDistribution, Child, MalnutritionRecord
from django.core.exceptions import ObjectDoesNotExist
import uuid
from django.http import JsonResponse

# 🔹 Create a Supplement
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_supplement(request):
    try:
        data = request.data
        print(data)
        supplement = Supplement.objects.create(
            id=uuid.uuid4(),  # Explicitly set the UUID for the new supplement
            name=data.get("name"),
            description=data.get("description", ""),
            unit=data.get("unit", "units")
        )
        return Response({"message": "Supplement created successfully", "id": str(supplement.id)}, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# 🔹 Retrieve All Supplements
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_supplements(request):
    supplements = Supplement.objects.all().values("id", "name", "description", "unit")  # Include the new `id` field
    return Response({"supplements": list(supplements)}, status=status.HTTP_200_OK)

# 🔹 Update a Supplement
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_supplement(request, supplement_id):
    try:
        data = request.data
        supplement = Supplement.objects.get(id=supplement_id)

        # Update fields if provided
        supplement.name = data.get("name", supplement.name)
        supplement.description = data.get("description", supplement.description)
        supplement.unit = data.get("unit", supplement.unit)
        supplement.save()

        return Response({"message": "Supplement updated successfully", "id": str(supplement.id)}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"message": "Supplement not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# 🔹 Delete a Supplement
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_supplement(request, supplement_id):
    try:
        supplement = Supplement.objects.get(id=supplement_id)
        supplement.delete()
        return Response({"message": "Supplement deleted successfully", "id": str(supplement_id)}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"message": "Supplement not found"}, status=status.HTTP_404_NOT_FOUND)

# 🔹 Update Anganwadi Supplement Stock
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_anganwadi_supplement(request):
    try:
        data = request.data
        anganwadi_user = AnganwadiUser.objects.get(id=data.get("anganwadi_user_id"))  # Fetch Anganwadi user by ID
        supplement = Supplement.objects.get(id=data.get("supplement_id"))

        # Update the stock if it exists
        anganwadi_supplement = AnganwadiSupplement.objects.get(
            anganwadi_user=anganwadi_user,
            supplement=supplement
        )
        anganwadi_supplement.quantity = data.get("quantity", anganwadi_supplement.quantity)
        anganwadi_supplement.save()

        return Response({"message": "Supplement stock updated successfully", "id": anganwadi_supplement.id}, status=status.HTTP_200_OK)
    except AnganwadiSupplement.DoesNotExist:
        return Response({"message": "Supplement stock not found"}, status=status.HTTP_404_NOT_FOUND)
    except ObjectDoesNotExist as e:
        return Response({"message": str(e)}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# 🔹 Retrieve Anganwadi Supplement Stock
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_anganwadi_supplements(request):
    try:
        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)
        supplements = AnganwadiSupplement.objects.filter(anganwadi_user=anganwadi_user).select_related('supplement')
        data = [
            {
                "id": stock.id,
                "supplement_name": stock.supplement.name,
                "quantity": stock.quantity,
                "unit": stock.supplement.unit
            }
            for stock in supplements
        ]
        return Response({"supplements": data}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND)

# 🔹 Delete Anganwadi Supplement Stock
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_anganwadi_supplement(request, supplement_id):
    try:
        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)
        anganwadi_supplement = AnganwadiSupplement.objects.get(anganwadi_user=anganwadi_user, supplement_id=supplement_id)
        anganwadi_supplement.delete()
        return Response({"message": "Supplement stock deleted successfully", "id": supplement_id}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"message": "Supplement stock not found"}, status=status.HTTP_404_NOT_FOUND)

# 🔹 Distribute Supplement to a Child
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def distribute_supplement(request):
    try:
        # Extract data from the request
        child_id = request.data.get("child_id")
        supplement_id = request.data.get("supplement_id")
        quantity = request.data.get("quantity")
        malnutrition_record_id = request.data.get("malnutrition_record_id")  # New field

        # Validate required fields
        if not all([child_id, supplement_id, quantity]):
            return JsonResponse({"message": "Missing required fields"}, status=status.HTTP_400_BAD_REQUEST)

        # Fetch the related objects
        child = Child.objects.get(id=child_id)
        supplement = Supplement.objects.get(id=supplement_id)
        malnutrition_record = MalnutritionRecord.objects.get(id=malnutrition_record_id) if malnutrition_record_id else None
        anganwadi_user = request.user  # Assuming the logged-in user is the distributor

        # Create the supplement distribution record
        distribution = SupplementDistribution.objects.create(
            child=child,
            distributed_by=anganwadi_user,
            supplement=supplement,
            quantity=quantity,
            malnutrition_record=malnutrition_record  # Associate with the malnutrition record
        )

        return JsonResponse({
            "message": "Supplement distributed successfully",
            "distribution": {
                "id": str(distribution.id),
                "child": distribution.child.full_name,
                "supplement": distribution.supplement.name,
                "quantity": distribution.quantity,
                "malnutrition_record": str(distribution.malnutrition_record.id) if distribution.malnutrition_record else None,
                "distribution_date": distribution.distribution_date
            }
        }, status=status.HTTP_201_CREATED)

    except Child.DoesNotExist:
        return JsonResponse({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
    except Supplement.DoesNotExist:
        return JsonResponse({"message": "Supplement not found"}, status=status.HTTP_404_NOT_FOUND)
    except MalnutritionRecord.DoesNotExist:
        return JsonResponse({"message": "Malnutrition record not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return JsonResponse({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

