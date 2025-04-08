from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import AnganwadiUser
from ..models import SupplementRequest, Supplement
import uuid


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_all_anganwadi_users(request):
    try:
        anganwadi_users = AnganwadiUser.objects.all().values(
            "id",
            "full_name",
            "email",
            "phone_number",
            "center_name",
            "village",
            "district",
            "state",
            "pin_code",
            "is_active",
        )
        return Response(
            {"anganwadi_users": list(anganwadi_users)}, status=status.HTTP_200_OK
        )
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def request_supplements(request):
    try:
        data = request.data
        anganwadi_user = AnganwadiUser.objects.get(
            id=request.user.id
        )  # Fetch the logged-in Anganwadi user

        # Validate supplements data
        supplements = data.get("supplements", [])
        if not supplements:
            return Response(
                {"message": "No supplements provided in the request"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Create a new supplement request
        supplement_request = SupplementRequest.objects.create(
            id=uuid.uuid4(), anganwadi_user=anganwadi_user, supplements=supplements
        )

        return Response(
            {
                "message": "Supplement request created successfully",
                "request_id": str(supplement_request.id),
                "request_date": supplement_request.request_date,
            },
            status=status.HTTP_201_CREATED,
        )

    except AnganwadiUser.DoesNotExist:
        return Response(
            {"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_all_supplement_requests(request):
    try:
        # Fetch all supplement requests
        supplement_requests = (
            SupplementRequest.objects.all()
            .select_related("anganwadi_user")
            .order_by("-request_date")
        )

        # Prepare the response data
        requests_data = [
            {
                "id": str(request.id),
                "anganwadi_user": {
                    "id": str(request.anganwadi_user.id),
                    "full_name": request.anganwadi_user.full_name,
                    "center_name": request.anganwadi_user.center_name,
                    "village": request.anganwadi_user.village,
                    "district": request.anganwadi_user.district,
                    "state": request.anganwadi_user.state,
                },
                "supplements": request.supplements,
                "request_date": request.request_date,
                "status": request.status,
            }
            for request in supplement_requests
        ]

        return Response(
            {"supplement_requests": requests_data}, status=status.HTTP_200_OK
        )

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_anganwadi_supplement_requests(request):
    try:
        # Fetch the logged-in Anganwadi user
        anganwadi_user = AnganwadiUser.objects.get(id=request.user.id)

        # Fetch all supplement requests made by this Anganwadi user
        supplement_requests = SupplementRequest.objects.filter(
            anganwadi_user=anganwadi_user
        ).order_by("-request_date")

        # Prepare the response data
        requests_data = []
        for request_obj in supplement_requests:
            supplements_with_names = []
            for supplement in request_obj.supplements:
                supplement_id = supplement.get("id")
                quantity = supplement.get("quantity")
                try:
                    supplement_name = Supplement.objects.get(id=supplement_id).name
                except Supplement.DoesNotExist:
                    supplement_name = "Unknown Supplement"
                supplements_with_names.append(
                    {"id": supplement_id, "name": supplement_name, "quantity": quantity}
                )

            requests_data.append(
                {
                    "id": str(request_obj.id),
                    "supplements": supplements_with_names,
                    "request_date": request_obj.request_date,
                    "status": request_obj.status,
                }
            )

        return Response(
            {"supplement_requests": requests_data}, status=status.HTTP_200_OK
        )

    except AnganwadiUser.DoesNotExist:
        return Response(
            {"message": "Anganwadi user not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_supplement_requests_for_head(request):
    try:
        # Fetch all supplement requests made by Anganwadi users
        supplement_requests = SupplementRequest.objects.all().select_related('anganwadi_user').order_by('-request_date')

        # Prepare the response data
        requests_data = []
        for request_obj in supplement_requests:
            supplements_with_names = []
            for supplement in request_obj.supplements:
                supplement_id = supplement.get("id")
                quantity = supplement.get("quantity")
                try:
                    supplement_name = Supplement.objects.get(id=supplement_id).name
                except Supplement.DoesNotExist:
                    supplement_name = "Unknown Supplement"
                supplements_with_names.append({
                    "id": supplement_id,
                    "name": supplement_name,
                    "quantity": quantity
                })

            requests_data.append({
                "id": str(request_obj.id),
                "anganwadi_user": {
                    "id": str(request_obj.anganwadi_user.id),
                    "full_name": request_obj.anganwadi_user.full_name,
                    "center_name": request_obj.anganwadi_user.center_name,
                    "village": request_obj.anganwadi_user.village,
                    "district": request_obj.anganwadi_user.district,
                    "state": request_obj.anganwadi_user.state,
                },
                "supplements": supplements_with_names,
                "request_date": request_obj.request_date,
                "status": request_obj.status
            })

        return Response({"supplement_requests": requests_data}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
