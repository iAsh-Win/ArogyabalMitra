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

            # Create or update the supplement stock for the Anganwadi user
            anganwadi_supplement, created = AnganwadiSupplement.objects.update_or_create(
                anganwadi_user=anganwadi_user,
                supplement=supplement,
                defaults={"quantity": quantity}
            )

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
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
