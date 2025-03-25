from django.contrib import admin
from .models import HeadOfficer, AnganwadiUser, Child, HealthRecord, SupplementDistribution, MalnutritionRecord

admin.site.register(HeadOfficer)
admin.site.register(AnganwadiUser)
admin.site.register(Child)
admin.site.register(HealthRecord)
admin.site.register(SupplementDistribution)

@admin.register(MalnutritionRecord)
class MalnutritionRecordAdmin(admin.ModelAdmin):
    list_display = ('child', 'predicted_status', 'created_at')
    search_fields = ('child__id', 'predicted_status')
    list_filter = ('predicted_status', 'created_at')
