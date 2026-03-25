import re
from pathlib import Path

xml_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.xml")
out_path = xml_path.with_suffix(".subcats.txt")

pattern = re.compile(r"<subcat>(.*?)</subcat>")
subcats = set()
chunk_size = 1024 * 1024  # 1MB por iteración
processed_lines = 0

with xml_path.open("r", encoding="utf-8", errors="ignore") as f:
    chunk = ""
    while True:
        new_data = f.read(chunk_size)
        if not new_data:
            if chunk:
                for m in pattern.finditer(chunk):
                    subcats.add(m.group(1).strip())
            break
        
        chunk += new_data
        
        # Procesar hasta el último >
        last_close = chunk.rfind(">")
        if last_close != -1:
            to_process = chunk[:last_close + 1]
            for m in pattern.finditer(to_process):
                subcats.add(m.group(1).strip())
            chunk = chunk[last_close + 1:]
        
        processed_lines += 1
        if processed_lines % 10 == 0:
            print(f"  [{processed_lines}] Procesadas... {len(subcats)} únicas encontradas")

sorted_subcats = sorted(subcats)

with out_path.open("w", encoding="utf-8") as f:
    for subcat in sorted_subcats:
        f.write(subcat + "\n")

print(f"\nSubcategorías encontradas: {len(sorted_subcats)}")
print(f"Guardado en: {out_path}")
