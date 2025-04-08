from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Program, HeadOfficer
import uuid

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_program(request):
    try:
        data = request.data
        head_officer = HeadOfficer.objects.get(id=request.user.id)  # Fetch the logged-in head officer

        # Create a new program
        program = Program.objects.create(
            id=uuid.uuid4(),
            title=data.get("title"),
            description=data.get("description"),
            date=data.get("date"),
            created_by=head_officer
        )

        return Response({
            "message": "Program created successfully",
            "program_id": str(program.id),
            "title": program.title,
            "description": program.description,
            "date": program.date
        }, status=status.HTTP_201_CREATED)

    except HeadOfficer.DoesNotExist:
        return Response({"message": "Head officer not found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_programs(request):
    try:
        # Fetch all programs
        programs = Program.objects.all().select_related('created_by').order_by('-date')

        # Prepare the response data
        programs_data = [
            {
                "id": str(program.id),
                "title": program.title,
                "description": program.description,
                "date": program.date,
                "created_by": {
                    "id": str(program.created_by.id),
                    "full_name": program.created_by.full_name,
                    "designation": program.created_by.designation
                }
            }
            for program in programs
        ]

        return Response({"programs": programs_data}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
