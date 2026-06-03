import os
from ftplib import FTP

FTP_HOST = "ftp.omproduction.in"
FTP_USER = "omprouvr@trading.abdielaircon.com"
FTP_PASS = "Newpass@12346"

# List of files to upload and their relative paths
files_to_upload = [
    ("core/routes/web.php", "core/routes/web.php"),
    ("core/app/Lib/CurlRequest.php", "core/app/Lib/CurlRequest.php"),
    ("core/app/Lib/CurrencyDataProvider/CurrencyDataProvider.php", "core/app/Lib/CurrencyDataProvider/CurrencyDataProvider.php"),
    ("core/app/Lib/CurrencyDataProvider/Upstox.php", "core/app/Lib/CurrencyDataProvider/Upstox.php"),
    ("core/app/Http/Controllers/User/OptionChainController.php", "core/app/Http/Controllers/User/OptionChainController.php"),
    ("core/resources/views/templates/basic/user/options/chain.blade.php", "core/resources/views/templates/basic/user/options/chain.blade.php"),
]

local_base = "/Users/adityaverma/Downloads/vinance-22nulled/code/Files"

def ensure_remote_dir(ftp, path):
    parts = path.strip("/").split("/")
    current = ""
    for part in parts:
        if not part:
            continue
        current = f"{current}/{part}" if current else part
        try:
            ftp.mkd(current)
            print(f"Created remote directory: {current}")
        except Exception:
            # Directory already exists or error
            pass

def main():
    print(f"Connecting to FTP server {FTP_HOST}...")
    ftp = FTP(FTP_HOST)
    ftp.login(FTP_USER, FTP_PASS)
    print("FTP login successful.")

    for local_rel, remote_rel in files_to_upload:
        local_path = os.path.join(local_base, local_rel)
        if not os.path.exists(local_path):
            print(f"ERROR: Local file does not exist: {local_path}")
            continue

        remote_dir = os.path.dirname(remote_rel)
        if remote_dir:
            ensure_remote_dir(ftp, remote_dir)

        print(f"Uploading {local_rel} to remote {remote_rel}...")
        with open(local_path, "rb") as f:
            ftp.storbinary(f"STOR {remote_rel}", f)
        print("Upload complete.")

    ftp.quit()
    print("Finished uploading all files.")

if __name__ == "__main__":
    main()
