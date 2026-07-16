import hashlib
import sys

SECRET_SALT = 'ZubairSecret2026'

def generate_unlock_code(device_id):
    raw = device_id + SECRET_SALT
    digest = hashlib.md5(raw.encode('utf-8')).hexdigest()
    return digest[:8].upper()

if __name__ == "__main__":
    print("========================================")
    print(" ZUBAIR TAILORS - UNLOCK CODE GENERATOR")
    print("========================================")
    
    if len(sys.argv) > 1:
        device_id = sys.argv[1]
    else:
        device_id = input("Enter the customer's Device ID: ").strip()
        
    if not device_id:
        print("Error: Device ID cannot be empty.")
        sys.exit(1)
        
    code = generate_unlock_code(device_id)
    print(f"\nDevice ID:   {device_id}")
    print(f"UNLOCK CODE: {code}\n")
    print("Give this exact unlock code to the customer.")
