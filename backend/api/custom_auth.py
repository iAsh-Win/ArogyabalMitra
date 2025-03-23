from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .models import AnganwadiUser, HeadOfficer  # Adjust the import based on your project structure
import jwt
from django.conf import settings



class CustomAuthentication(BaseAuthentication):
# Static Secret Key (same as in CustomAuthentication)
    secret_key = settings.JWT_SECRET_KEY
    def authenticate(self, request):
        auth_header = request.headers.get("Authorization")

        if not auth_header or not auth_header.startswith("Bearer "):
            return None  # No authentication provided, let other authentication classes handle it.

        token = auth_header.split(" ")[1]  # Extract the token from the "Bearer <token>"

        try:
            # Decode the JWT token
            payload = jwt.decode(token, self.secret_key, algorithms=["HS256"])

            # Extract user_id and role from the payload
            user_id = payload.get("user_id")
            role = payload.get("role")

            if not user_id or not role:
                raise AuthenticationFailed({
                    "success": False,
                    "message": "Invalid token: Missing user or role information."
                })

            # Check the role and fetch the corresponding model
            if role == "anganwadi":
                # If the role is 'anganwadi', check the AnganwadiUser model
                user = AnganwadiUser.objects.get(id=user_id)
            elif role == "head_officer":
                # If the role is 'head_officer', check the HeadOfficer model
                user = HeadOfficer.objects.get(id=user_id)
            else:
                raise AuthenticationFailed({
                    "success": False,
                    "message": "Role mismatch or unsupported role"
                })

            # Check if the user is active
            if not user.is_active:
                raise AuthenticationFailed({
                    "success": False,
                    "message": "User is inactive"
                })

            return (user, None)  # Return the authenticated user

        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed({
                "success": False,
                "message": "Token has expired"
            })

        except jwt.InvalidTokenError:
            raise AuthenticationFailed({
                "success": False,
                "message": "Invalid token"
            })

        except (AnganwadiUser.DoesNotExist, HeadOfficer.DoesNotExist):
            raise AuthenticationFailed({
                "success": False,
                "message": "User not found"
            })
