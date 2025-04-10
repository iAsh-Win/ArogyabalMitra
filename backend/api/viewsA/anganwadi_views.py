from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.core.exceptions import ObjectDoesNotExist
from rest_framework.permissions import IsAuthenticated, AllowAny

from ..models import AnganwadiUser
import uuid
from django.contrib.auth.hashers import make_password

# 🔹 Create Anganwadi User (Protected)
@api_view(['POST'])
@permission_classes([AllowAny])
def create_anganwadi_user(request):
    try:
        data = request.data
        user_id = uuid.uuid4()

        user = AnganwadiUser.objects.create(
            id=user_id,
            email=data.get("email"),
            password=make_password(data.get("password")),
            full_name=data.get("full_name"),
            phone_number=data.get("phone_number"),
            center_name=data.get("center_name"),
            center_code=data.get("center_code"),
            village=data.get("village"),
            district=data.get("district"),
            state=data.get("state"),
            pin_code=data.get("pin_code"),
            address=data.get("address"),
            is_active=True
        )

        return Response({"message": "Anganwadi User created successfully", "id": user.id}, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


# 🔹 Get All Anganwadi Users (Authenticated with Custom Auth)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_anganwadi_users(request):
    try:
        # Access the authenticated user from the request
        users = AnganwadiUser.objects.all()

        # Prepare the response data (you can format the user data as needed)
        user_data = [{"id": user.id, "email": user.email, "full_name": user.full_name} for user in users]

        return Response({"message": "Anganwadi users fetched successfully", "users": user_data}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)