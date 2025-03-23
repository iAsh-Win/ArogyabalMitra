from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password
from django.core.exceptions import ObjectDoesNotExist
from api.models import AnganwadiUser
from rest_framework.permissions import AllowAny
import jwt
import datetime
from django.conf import settings

# Static Secret Key (same as in CustomAuthentication)
secret_key = settings.JWT_SECRET_KEY

def generate_jwt_token(user, role="anganwadi"):
    payload = {
        "user_id": str(user.id),
        "role": role,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(days=1),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, secret_key, algorithm="HS256")


# ✅ Login for Anganwadi User
@api_view(['POST'])
@permission_classes([AllowAny])
def login_anganwadi_user(request):
    try:
        data = request.data
        email = data.get("email")
        password = data.get("password")
        user = AnganwadiUser.objects.get(email=email)

        if not check_password(password, user.password):
            return Response({"message": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.is_active:
            return Response({"message": "User account is inactive"}, status=status.HTTP_403_FORBIDDEN)

        token = generate_jwt_token(user)

        return Response({
            "token": token,
            "user": {
                "id": user.id,
                "email": user.email,
                "full_name": user.full_name,
                "center_name": user.center_name,
                "district": user.district
            },
            "message": "Login successful"
        }, status=status.HTTP_200_OK)

    except AnganwadiUser.DoesNotExist:
        return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)


# ✅ Logout (Token Invalidation - No Blacklist Support)
@api_view(['POST'])
def logout_user(request):
    try:
        token = request.headers.get("Authorization")

        if not token or not token.startswith("Bearer "):
            return Response({"message": "Authorization token is required."}, status=status.HTTP_400_BAD_REQUEST)

        # In manual JWT authentication, there's no built-in token blacklist system
        # Instead, frontend should just discard the token
        return Response({"message": "Logout successful (invalidate token on client-side)."}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
