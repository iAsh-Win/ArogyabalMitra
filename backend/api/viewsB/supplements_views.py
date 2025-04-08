from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Supplement, AnganwadiSupplement, AnganwadiUser, SupplementDistribution, Child, SupplementRequest
from django.core.exceptions import ObjectDoesNotExist
import uuid


# 🔹 Assign Supplements to Anganwadi
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def assign_supplements_to_anganwadi(request):
    try:
        data = request.data
        supplement_request_id = data.get("supplement_request_id")  # Get the supplement request ID

        # Validate supplement request ID
        if not supplement_request_id:
            return Response({"message": "Supplement request ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            supplement_request = SupplementRequest.objects.get(id=supplement_request_id)
        except SupplementRequest.DoesNotExist:
            return Response({"message": "Supplement request not found"}, status=status.HTTP_404_NOT_FOUND)

        anganwadi_user = supplement_request.anganwadi_user  # Get the Anganwadi user from the request
        supplements = supplement_request.supplements  # Use supplements from the request

        assigned_supplements = []
        for supplement_data in supplements:
            supplement = Supplement.objects.get(id=supplement_data["id"])
            quantity = supplement_data.get("quantity", 0)

            # Check if the AnganwadiSupplement record already exists
            anganwadi_supplement = AnganwadiSupplement.objects.filter(
                anganwadi_user=anganwadi_user,
                supplement=supplement
            ).first()

            if anganwadi_supplement:
                # Update the quantity if the record exists
                anganwadi_supplement.quantity += quantity
                anganwadi_supplement.save()
            else:
                # Create a new record if it doesn't exist
                anganwadi_supplement = AnganwadiSupplement.objects.create(
                    id=uuid.uuid4(),
                    anganwadi_user=anganwadi_user,
                    supplement=supplement,
                    quantity=quantity
                )

            assigned_supplements.append({
                "supplement_id": str(supplement.id),
                "name": supplement.name,
                "quantity": anganwadi_supplement.quantity,
                "unit": supplement.unit
            })

        # Update the status of the supplement request to "Approved"
        supplement_request.status = "Approved"
        supplement_request.save()

        return Response({
            "message": "Supplements assigned successfully and request approved",
            "assigned_supplements": assigned_supplements,
            "request_status": supplement_request.status
        }, status=status.HTTP_201_CREATED)

    except Supplement.DoesNotExist:
        return Response({"message": "One or more supplements not found"}, status=status.HTTP_404_NOT_FOUND)
    except SupplementRequest.DoesNotExist:
        return Response({"message": "Supplement request not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reject_supplement_request(request):
    try:
        data = request.data
        supplement_request_id = data.get("supplement_request_id")  # Get the supplement request ID

        # Validate supplement request ID
        if not supplement_request_id:
            return Response({"message": "Supplement request ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            supplement_request = SupplementRequest.objects.get(id=supplement_request_id)
        except SupplementRequest.DoesNotExist:
            return Response({"message": "Supplement request not found"}, status=status.HTTP_404_NOT_FOUND)

        # Update the status of the supplement request to "Rejected"
        supplement_request.status = "Rejected"
        supplement_request.save()

        return Response({
            "message": "Supplement request rejected successfully",
            "request_id": str(supplement_request.id),
            "request_status": supplement_request.status
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
