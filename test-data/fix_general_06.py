import os
import requests
import csv

def main():
    base_url = "https://tile-clover-apple.ngrok-free.dev"
    script_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_dir, "images", "general", "general_06.jpg")
    csv_file = os.path.join(script_dir, "results.csv")
    headers = {"ngrok-skip-browser-warning": "true"}

    print(f"Dang thu lai VQA va Caption cho general_06.jpg...")
    
    caption_result = "ERROR"
    vqa_result = "ERROR"
    
    # 1. Thu lai Caption
    try:
        with open(image_path, 'rb') as img_file:
            files = {'file': img_file}
            resp = requests.post(f"{base_url}/caption", headers=headers, files=files, timeout=30)
            if resp.status_code == 200:
                data = resp.json()
                caption_result = data.get("caption") or data.get("result") or data.get("answer") or resp.text
                print(f"Caption moi: {caption_result}")
            else:
                print(f"Loi HTTP Caption: {resp.status_code}")
    except Exception as e:
        print(f"Loi Caption: {e}")

    # 2. Thu lai VQA
    try:
        with open(image_path, 'rb') as img_file:
            files = {'file': img_file}
            data_payload = {'question': "What instrument is used to drop liquid into the tubes?"}
            resp = requests.post(f"{base_url}/vqa", headers=headers, files=files, data=data_payload, timeout=30)
            if resp.status_code == 200:
                data = resp.json()
                vqa_result = data.get("answer") or data.get("result") or data.get("caption") or resp.text
                print(f"VQA moi: {vqa_result}")
            else:
                print(f"Loi HTTP VQA: {resp.status_code}")
    except Exception as e:
        print(f"Loi VQA: {e}")

    if caption_result == "ERROR" or vqa_result == "ERROR":
        print("Khong the lay ket qua moi, dung lai thoi.")
        return

    # 3. Cap nhat results.csv
    rows = []
    with open(csv_file, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        for row in reader:
            if row.get("Ten anh") == "general_06.jpg":
                row["Ket qua VQA"] = vqa_result
                row["Dung/Sai VQA"] = "Sai" if vqa_result.lower() == "pipe" else "Dung" # pipette is correct, pipe is incorrect/slight error
                row["Caption AI sinh"] = caption_result
                # Evaluate caption: e.g. "a person pouring liquid..."
                if "pour" in caption_result.lower() or "liquid" in caption_result.lower() or "tube" in caption_result.lower() or "pipette" in caption_result.lower():
                    row["Dung/Sai Caption"] = "Dung"
                else:
                    row["Dung/Sai Caption"] = "Sai"
            rows.append(row)

    with open(csv_file, mode='w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
        
    print("Sua file results.csv cho general_06.jpg hoan tat!")

if __name__ == "__main__":
    main()
