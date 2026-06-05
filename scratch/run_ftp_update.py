import urllib.request
from ftplib import FTP
import os
from dotenv import load_dotenv

# Load local environment variables
load_dotenv()

FTP_HOST = "ftp.omproduction.in"
FTP_USER = "omprouvr@trading.abdielaircon.com"
FTP_PASS = "Newpass@12346"

local_file = "/Users/adityaverma/Downloads/vinance-22nulled/code/scratch/update_token.php"
remote_file = "update_token.php"
url = "https://trading.abdielaircon.com/update_token.php"

def generate_php_file(token):
    php_content = f"""<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = 'localhost';
$db   = 'omprouvr_trading';
$user = 'omprouvr_trading';
$pass = 'Newpass@12346';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {{
    $pdo = new PDO($dsn, $user, $pass, $options);
    $token = '{token}';
    
    $config = json_encode([
        'access_token' => [
            'title' => 'Access Token',
            'value' => $token
        ]
    ]);
    
    // First let's make sure the row exists (seed it if not, or update)
    $stmt = $pdo->prepare("UPDATE currency_data_providers SET configuration = :config, status = 1, is_default = 1 WHERE alias = 'Upstox'");
    $stmt->execute(['config' => $config]);
    
    echo "TOKEN_UPDATE_SUCCESS";
}} catch (Exception $e) {{
    echo "ERROR: " . $e->getMessage();
}}
"""
    with open(local_file, "w") as f:
        f.write(php_content)

def main():
    token = os.getenv("UPSTOX_ACCESS_TOKEN")
    if not token or token == "your_access_token_here":
        print("Error: UPSTOX_ACCESS_TOKEN not set in environment or .env file.")
        return
        
    print(f"Generating dynamic update_token.php locally...")
    generate_php_file(token)
    
    print(f"Connecting to FTP server {FTP_HOST}...")
    try:
        ftp = FTP(FTP_HOST)
        ftp.login(FTP_USER, FTP_PASS)
        print("FTP login successful.")
        
        # Upload
        print(f"Uploading local script {local_file} as remote {remote_file}...")
        with open(local_file, "rb") as f:
            ftp.storbinary(f"STOR {remote_file}", f)
        print("Upload complete.")
        
        # Trigger
        print(f"Triggering update on server via URL: {url}...")
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                result = response.read().decode('utf-8').strip()
                print(f"SERVER RESPONSE:\n----------------------\n{result}\n----------------------")
        except Exception as e:
            print(f"HTTP Trigger failed: {e}")
            result = ""
            
        # Delete remote file for security
        print(f"Cleaning up: deleting remote script {remote_file}...")
        try:
            ftp.delete(remote_file)
            print("Cleanup successful.")
        except Exception as e:
            print(f"Failed to delete remote file: {e}")
            
        ftp.quit()
        
        if "TOKEN_UPDATE_SUCCESS" in result:
            print("\nSUCCESS: Upstox access token was successfully updated in your live database!")
        else:
            print("\nFAILURE: Database update failed or could not be verified.")
            
    except Exception as e:
        print(f"FTP Connection/Execution failed: {e}")

if __name__ == "__main__":
    main()
