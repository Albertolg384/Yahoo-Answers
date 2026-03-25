"""
Análisis profundo: Mapear subcategorías por categoría principal
y recomendar combinaciones óptimas para el TFG
"""
from pathlib import Path
from collections import defaultdict

# Leer archivos
maincats_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.maincats.txt")
subcats_path = Path(r"C:\Users\manuc\Downloads\FullOct2007\FullOct2007.subcats.txt")

maincats = set()
with maincats_path.open("r", encoding="utf-8") as f:
    for line in f:
        cat = line.strip()
        if cat:
            maincats.add(cat)

subcats = set()
with subcats_path.open("r", encoding="utf-8") as f:
    for line in f:
        cat = line.strip()
        if cat:
            subcats.add(cat)

print("=" * 80)
print("ANÁLISIS PROFUNDO: Yahoo! Answers FullOct2007")
print("=" * 80)

print(f"\n[1] ESTADÍSTICAS GENERALES")
print(f"Categorías principales: {len(maincats)}")
print(f"Subcategorías: {len(subcats)}")
print(f"Ratio: {len(subcats) / len(maincats):.1f} subcats por maincat")

# Categorías ya tomadas (buscar variantes en inglés/español)
taken = {
    'Society & Culture', 'Sociedad y Cultura', 'Società e culture',
    'Travel', 'Viajes', 'Voyage', 'Viagens',
    'Food & Drink', 'Comer y Beber', 'Comidas e Bebidas',
    'Entertainment & Music', 'Entretenimiento', 'Unterhaltung & Musik',
    'Computers & Internet', 'Computadoras e Internet', 'Computer & Internet',
    'Consumer Electronics', 'Electrónica de Consumo', 'Eletrônicos',
    'Sports', 'Deportes', 'Esportes',
}

print(f"\n[2] CATEGORÍAS PRINCIPALES LIBRES (sin tomar)")
print("-" * 80)

libres = sorted([c for c in maincats if c not in taken])

for i, cat in enumerate(libres[:20], 1):
    print(f"   {i:2}. {cat}")

if len(libres) > 20:
    print(f"   ... y {len(libres) - 20} más")

# Buscar subcategorías relevantes para opciones educativas/científicas
print(f"\n[3] SUBCATEGORÍAS RELACIONADAS CON OPCIONES RECOMENDADAS")
print("-" * 80)

# Opción 1: Salud
print("\nHEALTH (Salud) - Subcategorías encontradas:")
health_subs = [s for s in subcats if any(
    x in s.lower() for x in ['health', 'salud', 'santé', 'medical', 'disease', 'doctor', 'enfermedad', 'médico']
)]
for sub in sorted(health_subs)[:15]:
    print(f"   • {sub}")
if len(health_subs) > 15:
    print(f"   ... y {len(health_subs) - 15} más")

# Opción 2: Embarazo/Paternidad
print("\nPREGNANCY & PARENTING - Subcategorías encontradas:")
preg_subs = [s for s in subcats if any(
    x in s.lower() for x in ['pregnancy', 'parenting', 'embarazo', 'bebé', 'baby', 'crianza', 'gravidez', 'gravidanza']
)]
for sub in sorted(preg_subs)[:15]:
    print(f"   • {sub}")
if len(preg_subs) > 15:
    print(f"   ... y {len(preg_subs) - 15} más")

# Opción 3: Educación
print("\nEDUCATION (Educación) - Subcategorías encontradas:")
edu_subs = [s for s in subcats if any(
    x in s.lower() for x in ['education', 'educación', 'school', 'escuela', 'university', 'universidad', 'teaching', 'enseñanza']
)]
for sub in sorted(edu_subs)[:15]:
    print(f"   • {sub}")
if len(edu_subs) > 15:
    print(f"   ... y {len(edu_subs) - 15} más")

# Opción 4: Ciencia Matemáticas
print("\nSCIENCE & MATHEMATICS - Subcategorías encontradas:")
sci_subs = [s for s in subcats if any(
    x in s.lower() for x in ['science', 'math', 'ciencia', 'matemática', 'physics', 'chemistry', 'biology', 'physic']
)]
for sub in sorted(sci_subs)[:15]:
    print(f"   • {sub}")
if len(sci_subs) > 15:
    print(f"   ... y {len(sci_subs) - 15} más")

# Opción 5: Negocios
print("\nBUSINESS & FINANCE - Subcategorías encontradas:")
biz_subs = [s for s in subcats if any(
    x in s.lower() for x in ['business', 'finance', 'negocios', 'finanza', 'investing', 'taxes', 'inversión']
)]
for sub in sorted(biz_subs)[:15]:
    print(f"   • {sub}")
if len(biz_subs) > 15:
    print(f"   ... y {len(biz_subs) - 15} más")

# Opción 6: Política
print("\nPOLITICS & GOVERNMENT - Subcategorías encontradas:")
pol_subs = [s for s in subcats if any(
    x in s.lower() for x in ['politics', 'government', 'política', 'gobierno', 'election', 'elección', 'política']
)]
for sub in sorted(pol_subs)[:15]:
    print(f"   • {sub}")
if len(pol_subs) > 15:
    print(f"   ... y {len(pol_subs) - 15} más")

print("\n" + "=" * 80)
print("Ejemplos")
print("=" * 80)

print("""
Health + Pregnancy & Parenting
   ├─ Subcategorías Health: ~""" + str(len(health_subs)) + """ encontradas
   ├─ Subcategorías Pregnancy: ~""" + str(len(preg_subs)) + """ encontradas
   ├─ Ventaja SNA: Red emocional, expertos identificables (médicos/madres)
   └─ Ventaja Datos: Subjetividad --> análisis de "Calidad de Respuestas"

Science & Mathematics + Education & Reference
   ├─ Subcategorías Science: ~""" + str(len(sci_subs)) + """ encontradas
   ├─ Subcategorías Education: ~""" + str(len(edu_subs)) + """ encontradas
   ├─ Ventaja SNA: Roles claros Mentor/Aprendiz
   └─ Ventaja Datos: Estructura formal, fácil XSD robusto

Business & Finance + Politics & Government
   ├─ Subcategorías Business: ~""" + str(len(biz_subs)) + """ encontradas
   ├─ Subcategorías Politics: ~""" + str(len(pol_subs)) + """ encontradas
   ├─ Ventaja SNA: Cliques cerrados, clustering alto
   └─ Ventaja Datos: Temporal (pre-2008 crisis), muy político
""")
