import urllib.request
from ftplib import FTP
import os

FTP_HOST = "ftp.omproduction.in"
FTP_USER = "omprouvr@trading.abdielaircon.com"
FTP_PASS = "Newpass@12346"

local_file = "/Users/adityaverma/Downloads/vinance-22nulled/code/scratch/update_token.php"
remote_file = "update_token.php"
url = "https://trading.abdielaircon.com/update_token.php"

def main():
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
