from django.contrib import admin
from django.urls import path, include

# Main project's URL configuration
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),  # Assuming 'api.urls' contains your application's URLs
]