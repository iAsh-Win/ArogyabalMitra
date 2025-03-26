from django.db import models
from django.contrib.auth.models import AbstractBaseUser
import uuid


# Head Officer Model
class HeadOfficer(AbstractBaseUser):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  # Hashed password
    full_name = models.CharField(max_length=255)  # Officer's full name
    phone_number = models.CharField(max_length=15, unique=True)  # Contact number
    designation = models.CharField(max_length=255)  # Example: District Supervisor
    department = models.CharField(max_length=255)  # Example: Health, Nutrition
    district = models.CharField(max_length=255)  # Work area
    state = models.CharField(max_length=255)  # Work area
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name', 'phone_number', 'designation', 'district', 'state']

    class Meta:
        db_table = "head_officers"

    def __str__(self):
        return f"{self.full_name} - {self.designation} ({self.district})"


# Anganwadi Worker Model
class AnganwadiUser(AbstractBaseUser):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    full_name = models.CharField(max_length=255)
    phone_number = models.CharField(max_length=15, unique=True)
    center_name = models.CharField(max_length=255)
    center_code = models.CharField(max_length=100, unique=True)
    village = models.CharField(max_length=255)
    district = models.CharField(max_length=255)
    state = models.CharField(max_length=255)
    pin_code = models.CharField(max_length=10)
    address = models.TextField()
    registration_date = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name', 'phone_number', 'center_name', 'village', 'district', 'state', 'pin_code']

    class Meta:
        db_table = "anganwadi_users"

    def __str__(self):
        return f"{self.full_name} - {self.center_name} ({self.village}, {self.pin_code})"


# Child Model
class Child(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    anganwadi_user = models.ForeignKey(AnganwadiUser, on_delete=models.CASCADE)  # Managed by which worker
    full_name = models.CharField(max_length=255)
    birth_date = models.DateField()
    gender = models.CharField(max_length=10, choices=[("Male", "Male"), ("Female", "Female"), ("Other", "Other")])
    aadhaar_number = models.CharField(max_length=12, unique=True, null=True, blank=True)

    # Address
    village = models.CharField(max_length=255)
    society_name = models.CharField(max_length=255, null=True, blank=True)  # New field added
    district = models.CharField(max_length=255)
    state = models.CharField(max_length=255)
    pin_code = models.CharField(max_length=10)

    # Parent Details
    father_name = models.CharField(max_length=255)
    father_contact = models.CharField(max_length=15, null=True, blank=True)
    mother_name = models.CharField(max_length=255)
    parent_aadhaar_number = models.CharField(max_length=12, unique=True, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "children"

    def __str__(self):
        return f"{self.full_name} ({self.gender}) - {self.society_name}, {self.village}, {self.pin_code}"  # Updated __str__


# Health Record Model
class HealthRecord(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    child = models.ForeignKey(Child, on_delete=models.CASCADE)  # Child being monitored
    weight_kg = models.FloatField()
    height_cm = models.FloatField()
    bmi = models.FloatField(null=True, blank=True)  # Auto-calculated
    hemoglobin_level = models.FloatField(null=True, blank=True)  # Blood test if available
    nutritional_status = models.CharField(
        max_length=50,
        choices=[("Normal", "Normal"), ("Moderate Malnutrition", "Moderate Malnutrition"), ("Severe Malnutrition", "Severe Malnutrition")],
    )
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "health_records"

    def __str__(self):
        return f"{self.child.full_name} - {self.nutritional_status}"




# Supplement Model
class Supplement(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)  # Add UUID primary key
    name = models.CharField(max_length=255, unique=True)  # Name of the supplement
    description = models.TextField(null=True, blank=True)  # Optional description
    unit = models.CharField(max_length=50, default="units")  # Unit of measurement (e.g., bottles, sachets)

    def __str__(self):
        return self.name


# Anganwadi Supplement Model
class AnganwadiSupplement(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)  # Add UUID primary key
    anganwadi_user = models.ForeignKey(AnganwadiUser, on_delete=models.CASCADE)  # Link to Anganwadi user
    supplement = models.ForeignKey(Supplement, on_delete=models.CASCADE)  # Link to the supplement
    quantity = models.PositiveIntegerField(default=0)  # Quantity of the supplement available
    
    def __str__(self):
        return f"{self.anganwadi_user.email} - {self.supplement.name} ({self.quantity} {self.supplement.unit})"




class MalnutritionRecord(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)  # Add UUID primary key
    child = models.ForeignKey('Child', on_delete=models.CASCADE, related_name='malnutrition_records')
    weight = models.FloatField(null=True, blank=True)
    height = models.FloatField(null=True, blank=True)
    muac = models.FloatField(null=True, blank=True)  # Mid-upper arm circumference
    meal_frequency = models.IntegerField(null=True, blank=True)
    dietary_diversity_score = models.FloatField(null=True, blank=True)
    clean_water = models.BooleanField(null=True, blank=True)
    illnesses = models.JSONField(default=list, blank=True)  # Array of illnesses

    waz = models.FloatField(null=True, blank=True)  # Weight-for-age Z-score
    haz = models.FloatField(null=True, blank=True)  # Height-for-age Z-score
    whz = models.FloatField(null=True, blank=True)  # Weight-for-height Z-score
    muac_z = models.FloatField(null=True, blank=True)  # MUAC Z-score

    predicted_status = models.CharField(max_length=255, null=True, blank=True)
    recommended_foods = models.JSONField(default=list, blank=True)  # Array of food recommendations
    supplements = models.JSONField(default=list, blank=True)  # Array of supplement data
    nutrient_deficiencies = models.JSONField(default=list, blank=True)  # Array of nutrient deficiencies

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"MalnutritionRecord for Child ID {self.child.id}"
    

# Supplement Distribution Model
class SupplementDistribution(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    child = models.ForeignKey(Child, on_delete=models.CASCADE)  # Which child received the supplement
    distributed_by = models.ForeignKey(AnganwadiUser, on_delete=models.CASCADE)  # Anganwadi worker who provided it
    supplement = models.ForeignKey(Supplement, on_delete=models.CASCADE)  # Link to the Supplement model
    quantity = models.PositiveIntegerField()  # Quantity of the supplement distributed
    malnutrition_record = models.ForeignKey(  # Link to the MalnutritionRecord
        MalnutritionRecord, on_delete=models.CASCADE, null=True, blank=True, related_name="supplement_distributions"
    )
    distribution_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "supplement_distribution"

    def __str__(self):
        return f"{self.supplement.name} - {self.child.full_name} ({self.quantity} {self.supplement.unit})"


class SupplementRequest(models.Model):
    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)  # Unique ID for the request
    anganwadi_user = models.ForeignKey(AnganwadiUser, on_delete=models.CASCADE)  # Link to the requesting Anganwadi user
    supplements = models.JSONField(default=list)  # Array of supplements with IDs and quantities
    request_date = models.DateTimeField(auto_now_add=True)  # Date when the request was made
    status = models.CharField(
        max_length=50,
        choices=[("Pending", "Pending"), ("Approved", "Approved"), ("Rejected", "Rejected")],
        default="Pending"
    )  # Status of the request

    def __str__(self):
        return f"Request by {self.anganwadi_user.full_name} on {self.request_date}"
