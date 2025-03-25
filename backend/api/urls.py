from django.urls import path
from .viewsA import auth_views, anganwadi_views, child_views, utility_views, malnutrtion_views, supplement_views
from .viewsB import auth_view, supplements_views
from .viewsA.supplement_views import distribute_supplement

urlpatterns = [
    path('logout/', auth_views.logout_user, name="logout_user"),

    # 🔹 Authentication Routes
    path('anganwadi/login', auth_views.login_anganwadi_user, name="login_anganwadi_user"),  # Corrected view name

    # 🔹 Anganwadi User Routes
    path('anganwadi/create', anganwadi_views.create_anganwadi_user, name="create_anganwadi_user"),
    path('anganwadi/users', anganwadi_views.get_anganwadi_users, name="get_anganwadi_users"),

    # 🔹 Child Management Routes
    path('anganwadi/children', child_views.get_children, name="get_children"),
    path('anganwadi/children/<str:child_id>', child_views.get_child, name="get_child"),

    path('anganwadi/children/create/', child_views.create_child, name="create_child"),  # Ensure this line exists

    path('anganwadi/children/update/<str:child_id>', child_views.update_child, name="update_child"),
    path('anganwadi/children/delete/<str:child_id>', child_views.delete_child, name="delete_child"),
    path('anganwadi/getfood', utility_views.get_csvFoodNames, name="get_children_csv"),

    path('anganwadi/check_malnutrtion/<str:child_id>', malnutrtion_views.check_malnutrition, name='check_malnutrition'),
    path('anganwadi/get_child_report/<str:child_id>', malnutrtion_views.get_child_report, name='get_child_report'),  # New API

    path('head_officer/login', auth_view.login_head_officer, name="login_head_officer"),

    # 🔹 Supplement Routes
    path('supplements', supplement_views.get_supplements, name='get_supplements'),
    path('supplements/create', supplement_views.create_supplement, name='create_supplement'),
    path('supplements/update/<str:supplement_id>', supplement_views.update_supplement, name='update_supplement'),
    path('supplements/delete/<str:supplement_id>', supplement_views.delete_supplement, name='delete_supplement'),
    
    path('anganwadi-supplements', supplement_views.get_anganwadi_supplements, name='get_anganwadi_supplements'),
    path('anganwadi-supplements/update', supplement_views.update_anganwadi_supplement, name='update_anganwadi_supplement'),
    path('anganwadi-supplements/delete/<str:supplement_id>', supplement_views.delete_anganwadi_supplement, name='delete_anganwadi_supplement'),

    # 🔹 Assign Supplements to Anganwadi Route
    path('anganwadi-supplements/assign', supplements_views.assign_supplements_to_anganwadi, name='assign_supplements_to_anganwadi'),

    # 🔹 Supplement Distribution Route
    path('supplements/distribute', distribute_supplement, name='distribute_supplement'),
]
