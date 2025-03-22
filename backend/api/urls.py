from django.urls import path
from .views import auth_views, anganwadi_views, child_views

urlpatterns = [
    # 🔹 Authentication Routes
    path('login/anganwadi/', auth_views.login_anganwadi, name="login_anganwadi"),
    path('login/head_officer/', auth_views.login_head_officer, name="login_head_officer"),
    path('logout/', auth_views.logout_user, name="logout_user"),  # Added logout route for both users

    # 🔹 Anganwadi User Routes
    path('anganwadi/create/', anganwadi_views.create_anganwadi_user, name="create_anganwadi_user"),
    path('anganwadi/users/', anganwadi_views.get_anganwadi_users, name="get_anganwadi_users"),  # Added route for fetching Anganwadi users

    # 🔹 Child Management Routes
    path('children/', child_views.get_children, name="get_children"),
    path('children/<uuid:child_id>/', child_views.get_child, name="get_child"),
    path('children/create/', child_views.create_child, name="create_child"),
    path('children/update/<uuid:child_id>/', child_views.update_child, name="update_child"),
    path('children/delete/<uuid:child_id>/', child_views.delete_child, name="delete_child"),
]
