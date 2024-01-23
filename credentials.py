import json
import subprocess

# Specify the path to the file containing JSON data
file_path = 'tempcred.txt'

# Read JSON data from the file
with open(file_path, 'r') as file:
    json_data = file.read()

# Load JSON data
data = json.loads(json_data)

# Extract values
access_key_id = data["Credentials"]["AccessKeyId"]
secret_access_key = data["Credentials"]["SecretAccessKey"]
session_token = data["Credentials"]["SessionToken"]

# Use the AWS CLI to dynamically get the AWS account ID
account_id = "$CLIENT_ACCOUNT_ID"
#subprocess.check_output(['aws', 'sts', 'get-caller-identity', '--output', 'json']).decode('utf-8')
#account_id = json.loads(account_id)['Account']

# Write the credentials to a file named "credentials" in the current directory
with open('credentials', 'w') as credentials_file:
    credentials_file.write(f"[{account_id}]\n")
    credentials_file.write(f"aws_access_key_id = {access_key_id}\n")
    credentials_file.write(f"aws_secret_access_key = {secret_access_key}\n")
    credentials_file.write(f"aws_session_token = {session_token}\n")

# Configure AWS CLI with extracted values for the new profile
subprocess.run(['aws', 'configure', '--profile', account_id, 'set', 'aws_access_key_id', access_key_id])
subprocess.run(['aws', 'configure', '--profile', account_id, 'set', 'aws_secret_access_key', secret_access_key])
subprocess.run(['aws', 'configure', '--profile', account_id, 'set', 'aws_session_token', session_token])

# Set the default region for the new profile
subprocess.run(['aws', 'configure', '--profile', account_id, 'set', 'region', 'ap-south-1'])

# Optionally, set the default output format to JSON
subprocess.run(['aws', 'configure', '--profile', account_id, 'set', 'output', 'json'])
