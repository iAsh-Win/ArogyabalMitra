from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import AnganwadiUser

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_all_anganwadi_users(request):
    try:
        anganwadi_users = AnganwadiUser.objects.all().values(
            "id", "full_name", "email", "phone_number", "center_name", "village", "district", "state", "pin_code", "is_active"
        )
        return Response({"anganwadi_users": list(anganwadi_users)}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
