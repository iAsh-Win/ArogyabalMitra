from django.urls import path
from .viewsA import auth_views, anganwadi_views, child_views, utility_views, malnutrtion_views, supplement_views
from .viewsB import auth_view, supplements_views, child_view, statistics_view
from .viewsA.supplement_views import distribute_supplement
from .viewsB.anganwadi_views import get_all_anganwadi_users, request_supplements, get_all_supplement_requests, get_anganwadi_supplement_requests, get_supplement_requests_for_head
from .viewsA.malnutrtion_views import get_child_reports, get_child_report
from .viewsA.child_views import get_children_with_malnutrition_reports
from .viewsB.supplements_views import reject_supplement_request, assign_supplements_to_anganwadi
from .viewsB.program_views import create_program, get_programs
from .viewsA.profile_data import get_anganwadi_profile_data

urlpatterns = [
    # 🔹 ViewsA - Authentication Routes
    path('logout/', auth_views.logout_user, name="logout_user"),
    path('anganwadi/login', auth_views.login_anganwadi_user, name="login_anganwadi_user"),

    # 🔹 ViewsA - Anganwadi User Management
    path('anganwadi/create', anganwadi_views.create_anganwadi_user, name="create_anganwadi_user"),
    path('anganwadi/users', anganwadi_views.get_anganwadi_users, name="get_anganwadi_users"),
    path('anganwadi/profile', get_anganwadi_profile_data, name="get_anganwadi_profile_data"),

    # 🔹 ViewsA - Child Management
    path('anganwadi/children', child_views.get_children, name="get_children"),
    path('anganwadi/children/<str:child_id>', child_views.get_child, name="get_child"),
    path('anganwadi/children/create/', child_views.create_child, name="create_child"),
    path('anganwadi/children/update/<str:child_id>', child_views.update_child, name="update_child"),
    path('anganwadi/children/delete/<str:child_id>', child_views.delete_child, name="delete_child"),
    path('anganwadi/children_with_reports/', get_children_with_malnutrition_reports, name="get_children_with_reports"),

    # 🔹 ViewsA - Utility Routes
    path('anganwadi/getfood', utility_views.get_csvFoodNames, name="get_children_csv"),

    # 🔹 ViewsA - Malnutrition Management
    path('anganwadi/check_malnutrtion/<str:child_id>', malnutrtion_views.check_malnutrition, name='check_malnutrition'),
    path('anganwadi/get_child_report/<str:malnutrition_record_id>', get_child_report, name='get_child_report'),
    path('anganwadi/get_child_reports/<str:child_id>', get_child_reports, name="get_child_reports"),

    # 🔹 ViewsA - Supplement Management
    path('supplements', supplement_views.get_supplements, name='get_supplements'),
    path('supplements/create', supplement_views.create_supplement, name='create_supplement'),
    path('supplements/update/<str:supplement_id>', supplement_views.update_supplement, name='update_supplement'),
    path('supplements/delete/<str:supplement_id>', supplement_views.delete_supplement, name='delete_supplement'),
    path('anganwadi-supplements', supplement_views.get_anganwadi_supplements, name='get_anganwadi_supplements'),
    path('anganwadi-supplements/update', supplement_views.update_anganwadi_supplement, name='update_anganwadi_supplement'),
    path('anganwadi-supplements/delete/<str:supplement_id>', supplement_views.delete_anganwadi_supplement, name='delete_anganwadi_supplement'),
    path('supplements/distribute/', distribute_supplement, name='distribute_supplement'),

    # 🔹 ViewsB - Authentication Routes
    path('head_officer/login', auth_view.login_head_officer, name="login_head_officer"),

    # 🔹 ViewsB - Anganwadi Management
    path('anganwadi/all', get_all_anganwadi_users, name="get_all_anganwadi_users"),
    path('anganwadi/request_supplements', request_supplements, name="request_supplements"),
    path('anganwadi/supplement_requests', get_anganwadi_supplement_requests, name="get_anganwadi_supplement_requests"),

    # 🔹 ViewsB - Head Officer Management
    path('head_officer/supplement_requests', get_supplement_requests_for_head, name="get_supplement_requests_for_head"),
    path('head_officer/programs/create', create_program, name="create_program"),
    path('head_officer/programs', get_programs, name="get_programs"),

    # 🔹 ViewsB - Supplement Management
    path('supplements/approve_request', assign_supplements_to_anganwadi, name='assign_supplements_to_anganwadi'),
    path('supplements/reject_request', reject_supplement_request, name='reject_supplement_request'),

    # 🔹 ViewsB - Child Management
    path('head_officer/children/all', child_view.get_all_children, name="get_all_children"),
    path('head_officer/child/<str:child_id>', child_view.get_child_details, name="get_child_details"),

    # 🔹 ViewsB - Statistics
    path('head_officer/statistics', statistics_view.get_malnutrition_statistics, name="get_malnutrition_statistics"),
]
