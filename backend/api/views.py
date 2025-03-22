from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import make_password, check_password
from django.core.exceptions import ObjectDoesNotExist
from rest_framework_simplejwt.tokens import RefreshToken
from .models import HeadOfficer, AnganwadiUser, Child
import uuid


# 🔹 Generate JWT Token
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


# 🔹 Login for AnganwadiUser (with JWT & ID)
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


# 🔹 Login for HeadOfficer (with JWT & ID)
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


# 🔹 Create Anganwadi User (Protected)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
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


# 🔹 Create Child (Protected)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_child(request):
    try:
        data = request.data
        anganwadi_user = AnganwadiUser.objects.get(id=data.get("anganwadi_user_id"))
        child_id = uuid.uuid4()

        child = Child.objects.create(
            id=child_id,
            anganwadi_user=anganwadi_user,
            full_name=data.get("full_name"),
            birth_date=data.get("birth_date"),
            gender=data.get("gender"),
            aadhaar_number=data.get("aadhaar_number"),
            village=data.get("village"),
            society_name=data.get("society_name"),
            district=data.get("district"),
            state=data.get("state"),
            pin_code=data.get("pin_code"),
            father_name=data.get("father_name"),
            father_contact=data.get("father_contact"),
            mother_name=data.get("mother_name"),
            parent_aadhaar_number=data.get("parent_aadhaar_number")
        )

        return Response({"message": "Child created successfully", "id": child.id}, status=status.HTTP_201_CREATED)
    except ObjectDoesNotExist:
        return Response({"error": "Anganwadi User not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


# 🔹 Retrieve All Children (Protected)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_children(request):
    children = Child.objects.all().values()
    return Response({"children": list(children)}, status=status.HTTP_200_OK)


# 🔹 Retrieve Single Child (Protected)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_child(request, child_id):
    try:
        child = Child.objects.get(id=child_id)
        return Response({
            "id": child.id,
            "full_name": child.full_name,
            "birth_date": child.birth_date,
            "gender": child.gender,
            "aadhaar_number": child.aadhaar_number,
            "village": child.village,
            "society_name": child.society_name,
            "district": child.district,
            "state": child.state,
            "pin_code": child.pin_code,
            "father_name": child.father_name,
            "father_contact": child.father_contact,
            "mother_name": child.mother_name,
            "parent_aadhaar_number": child.parent_aadhaar_number
        }, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"error": "Child not found"}, status=status.HTTP_404_NOT_FOUND)


# 🔹 Delete Child (Protected)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_child(request, child_id):
    try:
        child = Child.objects.get(id=child_id)
        child.delete()
        return Response({"message": "Child deleted successfully", "id": child_id}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"error": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
