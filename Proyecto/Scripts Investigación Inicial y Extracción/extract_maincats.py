import re
from pathlib import Path

# Ajusta esta ruta al XML real
xml_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.xml")
out_path = xml_path.with_suffix(".maincats.txt")

pattern = re.compile(r"<maincat>(.*?)</maincat>", re.IGNORECASE)

cats = set()

with xml_path.open("r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        for m in pattern.finditer(line):
            cats.add(m.group(1).strip())

sorted_cats = sorted(cats)

with out_path.open("w", encoding="utf-8") as f:
    for cat in sorted_cats:
        f.write(cat + "\n")

print(f"Categorias encontradas: {len(sorted_cats)}")
print(f"Guardado en: {out_path}")