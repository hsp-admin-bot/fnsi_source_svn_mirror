import zipfile
import os
import sys

def extract_zip_streaming(zip_file, extract_dir):
    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        for member in zip_ref.infolist():
            if member.is_dir():
                os.makedirs(os.path.join(extract_dir, member.filename), exist_ok=True)
            else:
                with zip_ref.open(member) as file:
                    with open(os.path.join(extract_dir, member.filename), 'wb') as outfile:
                        while True:
                            chunk = file.read(4096)
                            if not chunk:
                                break
                            outfile.write(chunk)

zip_file = sys.argv[1]
extract_dir = sys.argv[2]

if __name__ == "__main__":
    try:
        extract_zip_streaming(zip_file, extract_dir)
        print('OK')
    except Exception as e:
        print(e)