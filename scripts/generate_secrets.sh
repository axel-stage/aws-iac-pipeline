#!/bin/bash

python << EOPY
from cryptography.fernet import Fernet
import secrets

fernet_key = Fernet.generate_key()
jwt_token = secrets.token_hex(32)

print(f"fernet_key = \"{fernet_key.decode()}\"")
print(f"jwt_secret = \"{jwt_token}\"")
EOPY
