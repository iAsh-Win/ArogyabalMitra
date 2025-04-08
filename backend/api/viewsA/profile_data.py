from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import AnganwadiUser, Child, MalnutritionRecord, AnganwadiSupplement, Program
from datetime import date

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_anganwadi_profile_data(request):
    try:
        # Fetch the logged-in Anganwadi user
        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)

        # Fetch all children under this Anganwadi user
        children = Child.objects.filter(anganwadi_user=anganwadi_user)

        # Initialize malnutrition counts
        severe_count = 0
        moderate_count = 0
        normal_count = 0

        # Iterate through each child and consider their latest malnutrition record
        for child in children:
            latest_record = (
                MalnutritionRecord.objects.filter(child=child)
                .order_by('-created_at')
                .first()  # Get the latest record for the child
            )
            if latest_record:
                if latest_record.predicted_status == "Severe Malnutrition":
                    severe_count += 1
                elif latest_record.predicted_status == "Moderate Malnutrition":
                    moderate_count += 1
                else:
                    normal_count += 1
            else:
                # If no record exists, count the child as "normal"
                normal_count += 1

        # Total number of children under this Anganwadi user
        total_children = children.count()

        # Low stock supplements (quantity between 0 and 20)
        low_stock_supplements = AnganwadiSupplement.objects.filter(
            anganwadi_user=anganwadi_user,
            quantity__lte=20
        ).select_related('supplement').values('supplement__name', 'quantity')

        # Check for upcoming programs
        upcoming_programs = Program.objects.filter(date__gte=date.today()).count()

        # Prepare the response data
        response_data = {
            "anganwadi_user": {
                "id": str(anganwadi_user.id),
                "full_name": anganwadi_user.full_name,
                "center_name": anganwadi_user.center_name,
                "village": anganwadi_user.village,
                "district": anganwadi_user.district,
                "state": anganwadi_user.state,
            },
            "statistics": {
                "total_children": total_children,
                "malnutrition_status": {
                    "severe": severe_count,
                    "moderate": moderate_count,
                    "normal": normal_count
                },
                "low_stock_supplements": list(low_stock_supplements),
                "upcoming_programs": upcoming_programs
            }
        }

        return Response(response_data, status=status.HTTP_200_OK)

    except AnganwadiUser.DoesNotExist:
        return Response({"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
