from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Supplement, AnganwadiSupplement, AnganwadiUser, SupplementDistribution, Child
from django.core.exceptions import ObjectDoesNotExist
import uuid


# 🔹 Assign Supplements to Anganwadi
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def assign_supplements_to_anganwadi(request):
    try:
        data = request.data
        anganwadi_user = AnganwadiUser.objects.get(id=data.get("anganwadi_user_id"))  # Fetch Anganwadi user by ID

        supplements = data.get("supplements", [])
        if not supplements:
            return Response({"message": "No supplements provided"}, status=status.HTTP_400_BAD_REQUEST)

        assigned_supplements = []
        for supplement_data in supplements:
            supplement = Supplement.objects.get(id=supplement_data["supplement_id"])
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
                print(f"Updated existing supplement: {anganwadi_supplement}")
            else:
                # Create a new record if it doesn't exist
                anganwadi_supplement = AnganwadiSupplement.objects.create(
                    id=uuid.uuid4(),  # Explicitly set the UUID for the new record
                    anganwadi_user=anganwadi_user,
                    supplement=supplement,
                    quantity=quantity
                )
                print(f"Created new supplement: {anganwadi_supplement}")

            assigned_supplements.append({
                "supplement_id": str(supplement.id),
                "name": supplement.name,
                "quantity": anganwadi_supplement.quantity,
                "unit": supplement.unit
            })

        return Response({
            "message": "Supplements assigned successfully",
            "assigned_supplements": assigned_supplements
        }, status=status.HTTP_201_CREATED)

    except Supplement.DoesNotExist:
        return Response({"message": "One or more supplements not found"}, status=status.HTTP_404_NOT_FOUND)
    except AnganwadiUser.DoesNotExist:
        return Response({"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
