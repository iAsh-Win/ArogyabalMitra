from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from ..models import Child, AnganwadiUser, MalnutritionRecord, SupplementDistribution
from django.utils import timezone
from datetime import datetime
from django.db.models import Max
from django.shortcuts import get_object_or_404

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_all_children(request):
    try:
        children = Child.objects.all().select_related('anganwadi_user')

        children_data = []
        for child in children:
            # Calculate age
            today = timezone.now().date()
            birth_date = child.birth_date
            age_days = (today - birth_date).days
            age_years = age_days / 365.25
            age_months = int((age_days % 365.25) / 30.44)
            
            # Get latest malnutrition record
            latest_record = MalnutritionRecord.objects.filter(
                child=child
            ).order_by('-created_at').first()
            
            child_dict = {
                'id': str(child.id),
                'name': child.full_name,
                'age': {
                    'years': int(age_years),
                    'months': age_months
                },
                'center': {
                    'name': child.anganwadi_user.center_name,
                    'village': child.anganwadi_user.village
                },
                'malnutrition_status': latest_record.predicted_status if latest_record else None
            }
            children_data.append(child_dict)

        return Response({
            'children': children_data
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({
            'message': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_child_details(request, child_id):
    try:
        child = get_object_or_404(Child.objects.select_related('anganwadi_user'), id=child_id)

        # Calculate age
        today = timezone.now().date()
        birth_date = child.birth_date
        age_days = (today - birth_date).days
        age_years = age_days / 365.25
        age_months = int((age_days % 365.25) / 30.44)

        # Get latest malnutrition record
        latest_record = MalnutritionRecord.objects.filter(
            child=child
        ).order_by('-created_at').first()

        # Get supplement distributions for the latest record
        supplement_distributions = SupplementDistribution.objects.filter(
            child=child,
            malnutrition_record=latest_record
        ).select_related("supplement")

        # Track prescribed supplements and their distribution status
        supplements_with_distribution = []
        if latest_record and latest_record.supplements:
            for supplement in latest_record.supplements:
                supplement_name = supplement.get('name') if isinstance(supplement, dict) else str(supplement)
                distributed = next(
                    (
                        dist
                        for dist in supplement_distributions
                        if dist.supplement.name == supplement_name
                    ),
                    None,
                )
                supplements_with_distribution.append({
                    "name": supplement_name,
                    "id": supplement.get("id") if isinstance(supplement, dict) else None,
                    "quantity_distributed": distributed.quantity if distributed else None,
                    "distribution_date": distributed.distribution_date if distributed else None,
                })

        child_data = {
            'personal_info': {
                'id': str(child.id),
                'name': child.full_name,
                'gender': child.gender,
                'birth_date': child.birth_date,
                'age': {
                    'years': int(age_years),
                    'months': age_months
                },
                'aadhaar_number': child.aadhaar_number
            },
            'address': {
                'village': child.village,
                'society_name': child.society_name,
                'district': child.district,
                'state': child.state,
                'pin_code': child.pin_code
            },
            'parent_info': {
                'father_name': child.father_name,
                'father_contact': child.father_contact,
                'mother_name': child.mother_name,
                'parent_aadhaar_number': child.parent_aadhaar_number
            },
            'anganwadi_info': {
                'center_name': child.anganwadi_user.center_name,
                'center_code': child.anganwadi_user.center_code,
                'worker_name': child.anganwadi_user.full_name,
                'worker_contact': child.anganwadi_user.phone_number
            },
            'health_info': {
                'malnutrition_status': latest_record.predicted_status if latest_record else None,
                'latest_record': {
                    'weight': latest_record.weight if latest_record else None,
                    'height': latest_record.height if latest_record else None,
                    'muac': latest_record.muac if latest_record else None,
                    'waz': latest_record.waz if latest_record else None,
                    'haz': latest_record.haz if latest_record else None,
                    'whz': latest_record.whz if latest_record else None,
                    'recommended_supplements': supplements_with_distribution,
                    'nutrient_deficiencies': latest_record.nutrient_deficiencies if latest_record else [],
                    'record_date': latest_record.created_at if latest_record else None
                }
            }
        }

        return Response(child_data, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({
            'message': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)