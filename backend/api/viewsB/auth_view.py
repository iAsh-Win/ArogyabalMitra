from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password
from django.core.exceptions import ObjectDoesNotExist
from api.models import HeadOfficer, AnganwadiUser
from rest_framework.permissions import IsAuthenticated, AllowAny
import jwt
import datetime

# Static Secret Key (same as in CustomAuthentication)
SECRET_KEY = "your-very-secure-static-secret-key"

def generate_jwt_token(user, role="head_officer"):
    payload = {
        "user_id": str(user.id),
        "role": role,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(days=1),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")



# ✅ Login for Head Officer
@api_view(['POST'])
@permission_classes([AllowAny])

def login_head_officer(request):
    try:
        email = request.data.get("email")
        password = request.data.get("password")

        if not email or not password:
            return Response({"error": "Email and password are required."}, status=status.HTTP_400_BAD_REQUEST)

        officer = HeadOfficer.objects.get(email=email)

        if check_password(password, officer.password):
            token = generate_jwt_token(officer)  # Using manual JWT generation
            return Response({
                "message": "Login successful",
                "token": token,
                "officer": {
                    "id": officer.id,
                    "email": officer.email,
                    "full_name": officer.full_name,
                    "designation": officer.designation,
                    "district": officer.district
                }
            }, status=status.HTTP_200_OK)

        return Response({"error": "Invalid password"}, status=status.HTTP_401_UNAUTHORIZED)

    except ObjectDoesNotExist:
        return Response({"error": "Officer not found"}, status=status.HTTP_404_NOT_FOUND)

