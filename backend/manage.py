#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys
import socket


def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    # execute_from_command_line(sys.argv)
    
    # # Add this block to set default host and port
    # if len(sys.argv) == 2 and sys.argv[1] == "runserver":
    #     sys.argv += ["172.16.11.177:8000"]  # Set default host and port

    # execute_from_command_line(sys.argv)

    # Get the system's IPv4 address
    ipv4_address = socket.gethostbyname(socket.gethostname())
    
    # Add this block to set default host and port dynamically
    if len(sys.argv) == 2 and sys.argv[1] == "runserver":
        sys.argv += [f"{ipv4_address}:8000"]  # Use the dynamic IPv4 address

    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
