from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.core.exceptions import ObjectDoesNotExist
from ..models import AnganwadiUser, Child
import uuid

@api_view(['POST'])  # Ensure this decorator allows POST requests
@permission_classes([IsAuthenticated])
def create_child(request):
    try:
        data = request.data
        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)  # Ensure correct user ID is fetched

        # Create the child instance
        child = Child.objects.create(
            id=uuid.uuid4(),
            anganwadi_user=anganwadi_user,
            full_name=data.get("full_name"),
            birth_date=data.get("birth_date"),
            gender=data.get("gender"),
            aadhaar_number=data.get("aadhaar_number", None),  # Allow empty Aadhaar number
            village=data.get("village"),
            society_name=data.get("society_name", None),  # Allow empty society name
            district=data.get("district"),
            state=data.get("state"),
            pin_code=data.get("pin_code"),
            father_name=data.get("father_name"),
            father_contact=data.get("father_contact", None),  # Allow empty father contact
            mother_name=data.get("mother_name"),
            parent_aadhaar_number=data.get("parent_aadhaar_number", None)  # Allow empty parent Aadhaar number
        )

        return Response({"message": "Child created successfully", "id": str(child.id)}, status=status.HTTP_201_CREATED)

    except AnganwadiUser.DoesNotExist:
        return Response({"message": "Anganwadi User not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    

    
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
        return Response({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)

# 🔹 Delete Child (Protected)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_child(request, child_id):
    try:
        child = Child.objects.get(id=child_id)
        child.delete()
        return Response({"message": "Child deleted successfully", "id": child_id}, status=status.HTTP_200_OK)
    except ObjectDoesNotExist:
        return Response({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
    
    
# 🔹 Update Child (Protected)
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_child(request, child_id):
    try:
        data = request.data
        child = Child.objects.get(id=child_id)

        # Update fields if provided
        child.full_name = data.get("full_name", child.full_name)
        child.birth_date = data.get("birth_date", child.birth_date)
        child.gender = data.get("gender", child.gender)
        child.aadhaar_number = data.get("aadhaar_number", child.aadhaar_number)
        child.village = data.get("village", child.village)
        child.society_name = data.get("society_name", child.society_name)
        child.district = data.get("district", child.district)
        child.state = data.get("state", child.state)
        child.pin_code = data.get("pin_code", child.pin_code)
        child.father_name = data.get("father_name", child.father_name)
        child.father_contact = data.get("father_contact", child.father_contact)
        child.mother_name = data.get("mother_name", child.mother_name)
        child.parent_aadhaar_number = data.get("parent_aadhaar_number", child.parent_aadhaar_number)

        # Save the updated child instance
        child.save()

        # Return the updated child data
        return Response({
            "message": "Child updated successfully",
            "child": {
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
            }
        }, status=status.HTTP_200_OK)

    except ObjectDoesNotExist:
        return Response({"message": "Child not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
