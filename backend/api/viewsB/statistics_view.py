from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status as drf_status
from django.db.models import Count, Q
from ..models import Child, MalnutritionRecord

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_malnutrition_statistics(request):
    try:
        # Get all children with their latest malnutrition records using select_related
        children = Child.objects.select_related('anganwadi_user').all()
        total_children = children.count()

        # Get children with malnutrition records and prefetch related records
        children_with_records = Child.objects.filter(
            malnutrition_records__isnull=False
        ).select_related('anganwadi_user').prefetch_related('malnutrition_records').distinct()

        # Add child info to the response
        child_info = {}
        for child in children_with_records:
            child_info[child.id] = {
                'id': str(child.id),
                'name': child.full_name,
                'gender': child.gender,
                'birth_date': child.birth_date,
                'aadhaar_number': child.aadhaar_number,
                'father_name': child.father_name,
                'mother_name': child.mother_name
            }
        
        # Initialize counters and data structures
        malnutrition_data = {
            'total': 0,
            'no_malnutrition': 0,
            'moderate': 0,
            'severe': 0
        }
        
        # Initialize hotspots data with geographical information
        hotspots_data = {
            'severe': [],
            'moderate': []
        }
        
        # Process each child's latest malnutrition record
        for child in children_with_records:
            latest_record = child.malnutrition_records.order_by('-created_at').first()
            
            if latest_record:
                status = latest_record.predicted_status
                if status == 'Severe Malnutrition':
                    malnutrition_data['severe'] += 1
                    hotspots_data['severe'].append({
                        'location': child.village,
                        'district': child.district,
                        'state': child.state,
                        'pin_code': child.pin_code,
                        'center_name': child.anganwadi_user.center_name,
                        'center_code': child.anganwadi_user.center_code,
                        'count': 1,
                        'child': child_info[child.id],
                        'child': child_info[child.id],
                        'metrics': {
                            'waz': latest_record.waz,
                            'haz': latest_record.haz,
                            'whz': latest_record.whz,
                            'muac': latest_record.muac
                        }
                    })
                elif status == 'Moderate Malnutrition':
                    malnutrition_data['moderate'] += 1
                    hotspots_data['moderate'].append({
                        'location': child.village,
                        'district': child.district,
                        'state': child.state,
                        'pin_code': child.pin_code,
                        'center_name': child.anganwadi_user.center_name,
                        'center_code': child.anganwadi_user.center_code,
                        'count': 1,
                        'child': child_info[child.id],
                        'child': child_info[child.id],
                        'metrics': {
                            'waz': latest_record.waz,
                            'haz': latest_record.haz,
                            'whz': latest_record.whz,
                            'muac': latest_record.muac
                        }
                    })
                    
                elif status == 'No Malnutrition':
                    malnutrition_data['no_malnutrition'] += 1

        # Calculate total malnutrition cases
        malnutrition_data['total'] = malnutrition_data['severe'] + malnutrition_data['moderate']

        # Aggregate hotspot data by location
        for severity in ['severe', 'moderate']:
            location_data = {}
            for item in hotspots_data[severity]:
                key = (item['location'], item['district'], item['state'], item['pin_code'])
                if key not in location_data:
                    location_data[key] = {
                        'location': item['location'],
                        'district': item['district'],
                        'state': item['state'],
                        'pin_code': item['pin_code'],
                        'center_name': item['center_name'],
                        'center_code': item['center_code'],
                        'count': 0,
                        'child': item['child'],
                        'metrics': {
                            'waz': [],
                            'haz': [],
                            'whz': [],
                            'muac': []
                        }
                    }
                location_data[key]['count'] += 1
                for metric in ['waz', 'haz', 'whz', 'muac']:
                    if item['metrics'][metric] is not None:
                        location_data[key]['metrics'][metric].append(item['metrics'][metric])

            # Calculate average metrics for each location
            for loc_data in location_data.values():
                for metric in ['waz', 'haz', 'whz', 'muac']:
                    values = loc_data['metrics'][metric]
                    loc_data['metrics'][metric] = round(sum(values) / len(values), 2) if values else None

            # Sort locations by count
            hotspots_data[severity] = sorted(
                location_data.values(),
                key=lambda x: x['count'],
                reverse=True
            )

        statistics = {
            'total_children': total_children,
            'malnutrition_summary': {
                'total_malnutrition': malnutrition_data['total'],
                'no_malnutrition': malnutrition_data['no_malnutrition'],
                'severe_cases': malnutrition_data['severe'],
                'moderate_cases': malnutrition_data['moderate']
            },
            'hotspots': {
                'severe': hotspots_data['severe'],
                'moderate': hotspots_data['moderate']
            }
        }

        return Response(statistics, status=drf_status.HTTP_200_OK)

    except Exception as e:
        return Response(
            {'message': str(e)},
            status=drf_status.HTTP_400_BAD_REQUEST
        )