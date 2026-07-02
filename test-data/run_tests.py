import os
import sys
import csv
import time
from datetime import datetime
import requests

def main():
    base_url = "https://tile-clover-apple.ngrok-free.dev"
    if len(sys.argv) > 1:
        base_url = sys.argv[1]

    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_input = os.path.join(script_dir, "test_cases.csv")
    csv_output = os.path.join(script_dir, "results.csv")
    log_file = os.path.join(script_dir, "test_log.txt")
    images_root = os.path.join(script_dir, "images")

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    headers = {
        "ngrok-skip-browser-warning": "true"
    }

    print("\n=============================================")
    print("  KIEM THU TU DONG - API Y TE (PYTHON)")
    print("=============================================")
    print(f"  Base URL : {base_url}")
    print(f"  Thoi gian: {timestamp}")
    print(f"  CSV Input: {csv_input}")
    print("=============================================\n")

    # --- Kiem tra API truoc ---
    print("[*] Kiem tra Health API...", end="", flush=True)
    try:
        resp = requests.get(f"{base_url}/health", headers=headers, timeout=15)
        if resp.status_code == 200:
            status = resp.json().get("status", "unknown")
            print(f" OK - Status: {status}")
        else:
            print(f" THAT BAI! HTTP Code: {resp.status_code}")
            sys.exit(1)
    except Exception as e:
        print(" THAT BAI!")
        print(f"    Loi: {e}")
        print("    -> Kiem tra lai BaseUrl hoac API con song khong.")
        sys.exit(1)

    print("")

    # --- Doc CSV ---
    try:
        with open(csv_input, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            fieldnames = reader.fieldnames
            rows = list(reader)
    except Exception as e:
        print(f"Loi khi doc file CSV: {e}")
        sys.exit(1)

    results = []
    total = len(rows)
    fail_count = 0

    for idx, row in enumerate(rows, 1):
        image_name = row.get("Ten anh", "").strip()
        question = row.get("Cau hoi tieng Anh", "").strip()

        # Xac dinh thu muc anh (xray / clinical / general)
        if image_name.startswith("xray_"):
            folder = "xray"
        elif image_name.startswith("clinical_"):
            folder = "clinical"
        else:
            folder = "general"

        image_path = os.path.join(images_root, folder, image_name)
        print(f"[{idx}/{total}] {image_name}", end="", flush=True)

        if not os.path.exists(image_path):
            print(" -> SKIP (khong tim thay file)")
            row["Ket qua VQA"] = "FILE_NOT_FOUND"
            row["Caption AI sinh"] = "FILE_NOT_FOUND"
            row["Dung/Sai VQA"] = "?"
            row["Dung/Sai Caption"] = "?"
            results.append(row)
            fail_count += 1
            continue

        # ---- Goi Caption API ----
        caption_result = "ERROR"
        try:
            with open(image_path, 'rb') as img_file:
                files = {'file': img_file}
                resp = requests.post(f"{base_url}/caption", headers=headers, files=files, timeout=60)
                if resp.status_code == 200:
                    data = resp.json()
                    caption_result = data.get("caption") or data.get("result") or data.get("answer") or resp.text
                else:
                    caption_result = f"API_ERROR: HTTP {resp.status_code}"
                    fail_count += 1
        except Exception as e:
            caption_result = f"API_ERROR: {e}"
            fail_count += 1

        # ---- Goi VQA API ----
        vqa_result = "ERROR"
        try:
            with open(image_path, 'rb') as img_file:
                files = {'file': img_file}
                data_payload = {'question': question}
                resp = requests.post(f"{base_url}/vqa", headers=headers, files=files, data=data_payload, timeout=60)
                if resp.status_code == 200:
                    data = resp.json()
                    vqa_result = data.get("answer") or data.get("result") or data.get("caption") or resp.text
                else:
                    vqa_result = f"API_ERROR: HTTP {resp.status_code}"
                    fail_count += 1
        except Exception as e:
            vqa_result = f"API_ERROR: {e}"
            fail_count += 1

        # Cap nhat row
        row["Ket qua VQA"] = vqa_result
        row["Caption AI sinh"] = caption_result
        row["Dung/Sai VQA"] = "?"
        row["Dung/Sai Caption"] = "?"
        results.append(row)

        print("")
        print(f"    VQA    : {vqa_result[:60]}{'...' if len(vqa_result) > 60 else ''}")
        print(f"    Caption: {caption_result[:60]}{'...' if len(caption_result) > 60 else ''}")

    # --- Luu CSV ket qua ---
    try:
        with open(csv_output, mode='w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(results)
        print("\n=============================================")
        print("  HOAN TAT KIEM THU")
        print("=============================================")
        print(f"  Tong so anh da test : {total}")
        print(f"  So loi API          : {fail_count}")
        print(f"  Ket qua luu tai    : {csv_output}")
        print("\nBUOC TIEP THEO:")
        print("  1. Mo file results.csv")
        print("  2. Dien cot 'Dung/Sai VQA' va 'Dung/Sai Caption' (Dung/Sai)")
        print("  3. Chup man hinh 5 case tot + 2 case sai")
        print("=============================================\n")
    except Exception as e:
        print(f"Loi khi ghi file CSV: {e}")

    # Ghi log
    try:
        with open(log_file, mode='a', encoding='utf-8') as f:
            f.write(f"[{timestamp}] Test chay xong (Python). Total={total}, Fail={fail_count}, Output={csv_output}\n")
    except:
        pass

if __name__ == "__main__":
    main()
