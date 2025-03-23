from django.urls import path
from .viewsA import auth_views, anganwadi_views, child_views
from .viewsB import auth_view

urlpatterns = [
    path('logout/', auth_views.logout_user, name="logout_user"),

    # 🔹 Authentication Routes
    path('anganwadi/login', auth_views.login_anganwadi_user, name="login_anganwadi_user"),  # Corrected view name

    # 🔹 Anganwadi User Routes
    path('anganwadi/create', anganwadi_views.create_anganwadi_user, name="create_anganwadi_user"),
    path('anganwadi/users', anganwadi_views.get_anganwadi_users, name="get_anganwadi_users"),

    # 🔹 Child Management Routes
    path('anganwadi/children', child_views.get_children, name="get_children"),
    path('anganwadi/children/<uuid:child_id>', child_views.get_child, name="get_child"),
    path('anganwadi/children/create', child_views.create_child, name="create_child"),
    path('anganwadi/children/update/<uuid:child_id>', child_views.update_child, name="update_child"),
    path('anganwadi/children/delete/<uuid:child_id>', child_views.delete_child, name="delete_child"),


    path('head_officer/login', auth_view.login_head_officer, name="login_head_officer"),

]
