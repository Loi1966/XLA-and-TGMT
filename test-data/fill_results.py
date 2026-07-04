import csv
import os

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_file = os.path.join(script_dir, "results.csv")
    
    if not os.path.exists(csv_file):
        print(f"File not found: {csv_file}")
        return

    evaluations = {
        "xray_01.jpg": {"vqa": "Dung", "cap": "Dung"},
        "xray_02.jpg": {"vqa": "Sai", "cap": "Sai"},
        "xray_03.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_04.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_05.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_06.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_07.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_08.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_09.jpg": {"vqa": "Sai", "cap": "Dung"},
        "xray_10.jpg": {"vqa": "Sai", "cap": "Dung"},
        
        "clinical_01.jpg": {"vqa": "Sai", "cap": "Dung"},
        "clinical_02.jpg": {"vqa": "Sai", "cap": "Dung"},
        "clinical_03.jpg": {"vqa": "Dung", "cap": "Sai"},
        "clinical_04.jpg": {"vqa": "Sai", "cap": "Dung"},
        "clinical_05.jpg": {"vqa": "Dung", "cap": "Dung"},
        "clinical_06.jpg": {"vqa": "Sai", "cap": "Sai"},
        "clinical_07.jpg": {"vqa": "Dung", "cap": "Dung"},
        "clinical_08.jpg": {"vqa": "Dung", "cap": "Dung"},
        "clinical_09.jpg": {"vqa": "Sai", "cap": "Dung"},
        "clinical_10.jpg": {"vqa": "Sai", "cap": "Dung"},
        
        "general_01.jpg": {"vqa": "Dung", "cap": "Dung"},
        "general_02.jpg": {"vqa": "Dung", "cap": "Sai"},
        "general_03.jpg": {"vqa": "Dung", "cap": "Sai"},
        "general_04.jpg": {"vqa": "Dung", "cap": "Dung"},
        "general_05.jpg": {"vqa": "Dung", "cap": "Sai"},
        "general_06.jpg": {"vqa": "Sai", "cap": "Dung"},
        "general_07.jpg": {"vqa": "Dung", "cap": "Dung"},
        "general_08.jpg": {"vqa": "Sai", "cap": "Dung"},
        "general_09.jpg": {"vqa": "Dung", "cap": "Dung"},
        "general_10.jpg": {"vqa": "Dung", "cap": "Sai"},
    }

    rows = []
    with open(csv_file, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        for row in reader:
            img_name = row.get("Ten anh", "").strip()
            if img_name in evaluations:
                row["Dung/Sai VQA"] = evaluations[img_name]["vqa"]
                row["Dung/Sai Caption"] = evaluations[img_name]["cap"]
            rows.append(row)

    with open(csv_file, mode='w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
        
    print("Cap nhat Dung/Sai thanh cong!")

if __name__ == "__main__":
    main()
