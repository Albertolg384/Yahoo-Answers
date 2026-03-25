"""
Script de validación: verifica que se han extraído TODAS las categorías
y detecta si hay subcategorías también.
"""
import re
from pathlib import Path
from collections import Counter

xml_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.xml")
out_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.maincats.txt")

print("=" * 70)
print("VALIDACIÓN DE EXTRACCIÓN DE CATEGORÍAS")
print("=" * 70)

# Contadores
maincat_count = 0
maincat_unique = set()
subcat_count = 0
subcat_unique = set()

print("\n[1] Escaneando XML...")
with xml_path.open("r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f, 1):
        # Buscar maincats
        for m in re.finditer(r"<maincat>(.*?)</maincat>", line, re.IGNORECASE):
            maincat_count += 1
            cat = m.group(1).strip()
            maincat_unique.add(cat)
        
        # Buscar subcats (si existen)
        for m in re.finditer(r"<subcat>(.*?)</subcat>", line, re.IGNORECASE):
            subcat_count += 1
            cat = m.group(1).strip()
            subcat_unique.add(cat)

print(f"Maincats TOTALES en XML:    {maincat_count:,}")
print(f"Maincats ÚNICOS en XML:    {len(maincat_unique):,}")
print(f"Subcats TOTALES en XML:    {subcat_count:,}")
print(f"Subcats ÚNICOS en XML:     {len(subcat_unique):,}")

# Verificar archivo de salida
print("\n[2] Verificando archivo de salida...")
if out_path.exists():
    extracted = set()
    with out_path.open("r", encoding="utf-8") as f:
        for line in f:
            cat = line.strip()
            if cat:
                extracted.add(cat)
    
    print(f"Categorías EXTRAÍDAS:      {len(extracted)}")
    
    # Comparar
    print("\n[3] VALIDACIÓN...")
    if len(extracted) == len(maincat_unique):
        print(f"CORRECTO: Se extrajeron TODAS las {len(extracted)} únicas")
    else:
        print(f"DIFERENCIA: XML={len(maincat_unique)}, Extraído={len(extracted)}")
        
        missing = maincat_unique - extracted
        if missing:
            print(f"\nFALTANTES ({len(missing)}):")
            for cat in sorted(missing)[:10]:
                print(f"      - {cat}")
            if len(missing) > 10:
                print(f"      ... y {len(missing)-10} más")
        
        extra = extracted - maincat_unique
        if extra:
            print(f"\nEXTRAS ({len(extra)}):")
            for cat in sorted(extra)[:5]:
                print(f"      - {cat}")
else:
    print(f"No existe: {out_path}")

# Resumen estructura XML
print("\n[4] ESTRUCTURA DEL XML...")
print(f"- Tiene <maincat>: {'SÍ' if maincat_count > 0 else ' NO'}")
print(f"- Tiene <subcat>:  {'SÍ' if subcat_count > 0 else ' NO'}")

if subcat_count > 0:
    print(f"\nEl XML TAMBIÉN tiene subcategorías:")
    print(f"Se extrajeron {len(subcat_unique)} subcategorías únicas")
    print(f"Muestras: {list(sorted(subcat_unique))[:5]}")

print("\n" + "=" * 70)
print("FIN DE VALIDACIÓN")
print("=" * 70)
