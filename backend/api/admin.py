from django.contrib import admin
from .models import HeadOfficer, AnganwadiUser, Child, HealthRecord, SupplementDistribution

admin.site.register(HeadOfficer)
admin.site.register(AnganwadiUser)
admin.site.register(Child)
admin.site.register(HealthRecord)
admin.site.register(SupplementDistribution)
