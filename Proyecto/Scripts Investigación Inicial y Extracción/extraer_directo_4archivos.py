#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ALTERNATIVA: Extraer y dividir en 4 archivos directamente desde
el archivo original de 11 GB, sin generar el intermedio de 1,5 GB.

Salida:
  - yahoo_science.xml
  - yahoo_education.xml
  - yahoo_social.xml
  - yahoo_arts.xml
"""

import re
import time
import os
from pathlib import Path

# --- CONFIGURACIÓN ------------------------------------------------------------

INPUT  = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\FullOct2007.xml")
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

conteos       = {nombre: 0 for nombre in CATEGORIAS}
total_proc    = 0
bytes_proc    = 0
file_size     = INPUT.stat().st_size
t_inicio      = time.time()

print("=" * 65)
print("EXTRACCIÓN DIRECTA 11 GB --> 4 ARCHIVOS POR CATEGORÍA")
print("=" * 65)
print(f"Entrada: {INPUT}")
print(f"Tamaño:  {file_size / (1024**3):.2f} GB")
print(f"Salida:  {OUTDIR}")
print("Esto tardará aproximadamente 80 minutos. No cierres el terminal.\n")

buffer = ""
CHUNK  = 2 * 1024 * 1024  # 2 MB

with INPUT.open("r", encoding="utf-8", errors="ignore") as f:
    while True:
        dato = f.read(CHUNK)
        if not dato:
            dato = ""

        buffer += dato
        bytes_proc += len(dato.encode("utf-8", errors="ignore"))

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
            total_proc += 1

            m = RE_MAINCAT.search(bloque)
            if m:
                cat_val = m.group(1).strip()
                nombre  = VARIANTE_A_CAT.get(cat_val)
                if nombre:
                    handles[nombre].write(bloque + "\n")
                    conteos[nombre] += 1

            if total_proc % 100000 == 0:
                pct     = bytes_proc * 100 / file_size
                elapsed = time.time() - t_inicio
                eta     = (elapsed / max(pct, 0.01)) * (100 - pct)
                total_escritas = sum(conteos.values())
                print(f"{pct:5.1f}% | Procesadas: {total_proc:,} | "
                      f"Escritas: {total_escritas:,} | ETA: {eta/60:.1f} min")

        if not dato:
            break

# Cerrar archivos
for nombre, h in handles.items():
    h.write("</yahooAnswers>\n")
    h.close()

# --- RESUMEN ------------------------------------------------------------------
elapsed = time.time() - t_inicio
print("\n" + "=" * 65)
print("EXTRACCIÓN COMPLETADA")
print("=" * 65)
print(f"Tiempo: {elapsed/60:.1f} min  |  Total procesadas: {total_proc:,}\n")

for nombre in CATEGORIAS:
    ruta = OUTDIR / f"yahoo_{nombre}.xml"
    size = ruta.stat().st_size / (1024**2)
    print(f"yahoo_{nombre}.xml")
    print(f"Preguntas: {conteos[nombre]:,}  |  Tamaño: {size:.1f} MB")

print("\n" + "=" * 65)
