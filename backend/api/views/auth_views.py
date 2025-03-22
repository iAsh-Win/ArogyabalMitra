from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password
from django.core.exceptions import ObjectDoesNotExist
from rest_framework_simplejwt.tokens import RefreshToken
from api.models import HeadOfficer, AnganwadiUser

# Generate JWT Token
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Login for AnganwadiUser
@api_view(['POST'])
def login_anganwadi(request):
    try:
        email = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response({"error": "Email and password are required."}, status=status.HTTP_400_BAD_REQUEST)

        user = AnganwadiUser.objects.get(email=email)

        if check_password(password, user.password):
            tokens = get_tokens_for_user(user)
            return Response({
                "message": "Login successful",
                "tokens": tokens,
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "full_name": user.full_name,
                    "center_name": user.center_name,
                    "village": user.village
                }
            }, status=status.HTTP_200_OK)

        return Response({"error": "Invalid password"}, status=status.HTTP_401_UNAUTHORIZED)
    except ObjectDoesNotExist:
        return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

# Login for HeadOfficer
@api_view(['POST'])
def login_head_officer(request):
    try:
        email = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response({"error": "Email and password are required."}, status=status.HTTP_400_BAD_REQUEST)

        officer = HeadOfficer.objects.get(email=email)

        if check_password(password, officer.password):
            tokens = get_tokens_for_user(officer)
            return Response({
                "message": "Login successful",
                "tokens": tokens,
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

# Logout (Both Users)
@api_view(['POST'])
def logout_user(request):
    try:
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({"error": "Refresh token is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        token = RefreshToken(refresh_token)
        token.blacklist()
        return Response({"message": "Logout successful"}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
