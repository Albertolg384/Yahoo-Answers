#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PASO 1B: Dividir yahoo_4categorias.xml en 4 archivos separados,
uno por categoría. Así BaseX puede cargarlos sin problemas de memoria.

Salida:
  - yahoo_science.xml
  - yahoo_education.xml
  - yahoo_social.xml
  - yahoo_arts.xml
"""

import re
import time
from pathlib import Path

# --- CONFIGURACIÓN ------------------------------------------------------------

INPUT  = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\yahoo_4categorias.xml")
OUTDIR = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007")

CATEGORIAS = {
    "science": [
        "Science &amp; Mathematics", "Ciencia y Matemáticas",
        "Sciences et mathématiques", "Ciências e Matemática",
        "Wissenschaft &amp; Mathematik", "Scienze e matematica",
        "Ciencia y matemáticas",
    ],
    "education": [
        "Education &amp; Reference", "Educación", "Educación y Formación",
        "Educação e Referência", "Enseignement et référence",
        "Scuola ed educazione", "Schule &amp; Bildung", "Éducation",
    ],
    "social": [
        "Social Science", "Ciencias Sociales", "Ciencias sociales",
        "Sciences sociales", "Ciências Sociais", "Sozialwissenschaft",
        "Scienze sociali", "Ciencia social",
    ],
    "arts": [
        "Arts &amp; Humanities", "Arte y Humanidades", "Artes e Humanidades",
        "Arts et sciences humaines", "Kunst &amp; Geisteswissenschaft",
        "Arte e cultura", "Arte y humanidades",
    ],
}

# Mapa rápido variante --> nombre de archivo
VARIANTE_A_CAT = {}
for nombre, variantes in CATEGORIAS.items():
    for v in variantes:
        VARIANTE_A_CAT[v] = nombre

RE_MAINCAT = re.compile(r"<maincat>(.*?)</maincat>", re.DOTALL)
TAG_OPEN   = "<vespaadd>"
TAG_CLOSE  = "</vespaadd>"

# --- ABRIR ARCHIVOS DE SALIDA -------------------------------------------------

handles = {}
for nombre in CATEGORIAS:
    ruta = OUTDIR / f"yahoo_{nombre}.xml"
    h = ruta.open("w", encoding="utf-8")
    h.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    h.write(f'<yahooAnswers category="{nombre}">\n')
    handles[nombre] = h

conteos  = {nombre: 0 for nombre in CATEGORIAS}
t_inicio = time.time()

print("=" * 65)
print("DIVIDIENDO XML POR CATEGORÍA")
print("=" * 65)
print(f"Entrada: {INPUT}")
print(f"Salida:  {OUTDIR}")
print("Procesando...\n")

total = 0
buffer = ""
CHUNK  = 2 * 1024 * 1024  # 2 MB

with INPUT.open("r", encoding="utf-8", errors="ignore") as f:
    while True:
        dato = f.read(CHUNK)
        if not dato:
            dato = ""

        buffer += dato

        while True:
            ini = buffer.find(TAG_OPEN)
            if ini == -1:
                buffer = buffer[-(len(TAG_OPEN) - 1):]
                break
            fin = buffer.find(TAG_CLOSE, ini)
            if fin == -1:
                break
            fin += len(TAG_CLOSE)

            bloque = buffer[ini:fin]
            buffer = buffer[fin:]
            total += 1

            m = RE_MAINCAT.search(bloque)
            if m:
                cat_val = m.group(1).strip()
                nombre  = VARIANTE_A_CAT.get(cat_val)
                if nombre:
                    handles[nombre].write(bloque + "\n")
                    conteos[nombre] += 1

            if total % 50000 == 0:
                elapsed = time.time() - t_inicio
                print(f"{total:,} procesadas en {elapsed:.0f}s — "
                      + " | ".join(f"{k}: {v:,}" for k, v in conteos.items()))

        if not dato:
            break

# Cerrar archivos
for nombre, h in handles.items():
    h.write("</yahooAnswers>\n")
    h.close()

# --- RESUMEN ------------------------------------------------------------------
elapsed = time.time() - t_inicio
print("\n" + "=" * 65)
print("DIVISIÓN COMPLETADA")
print("=" * 65)
print(f"Tiempo: {elapsed/60:.1f} min  |  Total procesadas: {total:,}\n")

for nombre in CATEGORIAS:
    ruta  = OUTDIR / f"yahoo_{nombre}.xml"
    size  = ruta.stat().st_size / (1024**2)
    print(f"yahoo_{nombre}.xml")
    print(f"Preguntas: {conteos[nombre]:,}  |  Tamaño: {size:.1f} MB")

print()
print("SIGUIENTE PASO:")
print("En BaseX: Database --> New")
print("Carga yahoo_science.xml   --> base de datos: science")
print("Carga yahoo_education.xml --> base de datos: education")
print("Carga yahoo_social.xml    --> base de datos: social")
print("Carga yahoo_arts.xml      --> base de datos: arts")
print("O bien carga los 4 como documentos dentro de UNA sola BD.")
print("=" * 65)
