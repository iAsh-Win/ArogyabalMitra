from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Supplement, AnganwadiSupplement, AnganwadiUser, SupplementDistribution, Child
from django.core.exceptions import ObjectDoesNotExist
import uuid

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
                "id": stock.supplement.id,
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
        data = request.data
        print(data)  # Log the incoming request data for debugging

        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)  # Fetch Anganwadi user by ID
        child = Child.objects.get(id=data.get("child_id"))

        for supplement_data in data.get("supplements", []):
            supplement_id = supplement_data.get("supplement_id")
            quantity = supplement_data.get("quantity", 0)

            # Fetch the supplement
            try:
                supplement = Supplement.objects.get(id=supplement_id)
            except Supplement.DoesNotExist:
                return Response({"message": f"Supplement not found: {supplement_id}"}, status=status.HTTP_404_NOT_FOUND)

            # Check if the supplement exists in the Anganwadi's stock
            try:
                anganwadi_supplement = AnganwadiSupplement.objects.get(
                    anganwadi_user=anganwadi_user,
                    supplement=supplement
                )
            except AnganwadiSupplement.DoesNotExist:
                return Response({"message": f"Supplement not found in Anganwadi stock: {supplement_id}"}, status=status.HTTP_404_NOT_FOUND)

            # Ensure sufficient quantity is available
            if anganwadi_supplement.quantity < quantity:
                return Response({"message": f"Insufficient stock for supplement: {supplement.name}"}, status=status.HTTP_400_BAD_REQUEST)

            # Deduct the quantity from the Anganwadi's stock
            anganwadi_supplement.quantity -= quantity
            anganwadi_supplement.save()

            # Create a record in the SupplementDistribution model
            SupplementDistribution.objects.create(
                child=child,
                distributed_by=anganwadi_user,
                supplement=supplement,
                quantity=quantity
            )

        return Response({"message": "Supplements distributed successfully"}, status=status.HTTP_201_CREATED)

    except Child.DoesNotExist:
        return Response({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
    except AnganwadiUser.DoesNotExist:
        return Response({"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

