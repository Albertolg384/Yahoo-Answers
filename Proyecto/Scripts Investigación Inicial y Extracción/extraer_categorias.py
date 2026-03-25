#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PASO 1: Extraer preguntas de las 4 categorías seleccionadas
del archivo FullOct2007.xml (11 GB) y generar un XML filtrado.

Categorías: Science & Mathematics, Education & Reference,
            Social Science, Arts & Humanities
            (con todas sus variantes lingüísticas)

Uso: python extraer_categorias.py
Tiempo estimado: 30-60 minutos dependiendo del disco duro.
"""

import re
import os
import time
from pathlib import Path

# --- CONFIGURACIÓN ------------------------------------------------------------

XML_INPUT  = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\FullOct2007.xml")
XML_OUTPUT = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\yahoo_4categorias.xml")

# Todas las variantes lingüísticas de cada categoría principal.
CATEGORIAS_VARIANTES = {
    "Science & Mathematics": [
        "Science &amp; Mathematics",
        "Ciencia y Matemáticas",
        "Sciences et mathématiques",
        "Ciências e Matemática",
        "Wissenschaft &amp; Mathematik",
        "Scienze e matematica",
        "Ciencia y matemáticas",
    ],
    "Education & Reference": [
        "Education &amp; Reference",
        "Educación",
        "Educación y Formación",
        "Educação e Referência",
        "Enseignement et référence",
        "Scuola ed educazione",
        "Schule &amp; Bildung",
        "Éducation",
    ],
    "Social Science": [
        "Social Science",
        "Ciencias Sociales",
        "Ciencias sociales",
        "Sciences sociales",
        "Ciências Sociais",
        "Sozialwissenschaft",
        "Scienze sociali",
        "Ciencia social",
    ],
    "Arts & Humanities": [
        "Arts &amp; Humanities",
        "Arte y Humanidades",
        "Artes e Humanidades",
        "Arts et sciences humaines",
        "Kunst &amp; Geisteswissenschaft",
        "Arte e cultura",
        "Arte y humanidades",
    ],
}

# Conjunto plano de todas las variantes para búsqueda rápida.
TODAS_VARIANTES = set()
for variantes in CATEGORIAS_VARIANTES.values():
    TODAS_VARIANTES.update(variantes)

# --- LÓGICA PRINCIPAL ---------------------------------------------------------

def extraer_categorias():
    if not XML_INPUT.exists():
        print(f"No se encuentra el archivo: {XML_INPUT}")
        return

    file_size = XML_INPUT.stat().st_size
    print("=" * 70)
    print("EXTRACCIÓN DE CATEGORÍAS — Yahoo Answers FullOct2007")
    print("=" * 70)
    print(f"Entrada:  {XML_INPUT}")
    print(f"Salida:   {XML_OUTPUT}")
    print(f"Tamaño:   {file_size / (1024**3):.2f} GB")
    print(f"Buscando: {sum(len(v) for v in CATEGORIAS_VARIANTES.values())} variantes en 4 categorías")
    print("-" * 70)
    print("Esto puede tardar entre 30 y 60 minutos. No cierres el terminal.")
    print("-" * 70 + "\n")

    # Contadores
    total_escritas   = 0
    total_procesadas = 0
    conteos_por_cat  = {cat: 0 for cat in CATEGORIAS_VARIANTES}
    bytes_procesados = 0
    t_inicio         = time.time()

    # Regex para detectar la categoría principal dentro de un bloque
    re_maincat = re.compile(r"<maincat>(.*?)</maincat>", re.DOTALL)

    with XML_INPUT.open("r", encoding="utf-8", errors="ignore") as f_in, \
         XML_OUTPUT.open("w", encoding="utf-8") as f_out:

        # Cabecera del XML de salida
        f_out.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f_out.write('<yahooAnswers>\n')

        buffer = ""
        CHUNK = 2 * 1024 * 1024   # leer de 2 MB en 2 MB
        TAG_OPEN  = "<vespaadd>"
        TAG_CLOSE = "</vespaadd>"

        while True:
            dato = f_in.read(CHUNK)
            if not dato:
                # Procesar lo que quede en el buffer
                dato = ""

            buffer += dato
            bytes_procesados += len(dato.encode("utf-8", errors="ignore"))

            # Extraer bloques completos <vespaadd>...</vespaadd>
            while True:
                inicio = buffer.find(TAG_OPEN)
                if inicio == -1:
                    # No hay bloque abierto; conservar solo los últimos bytes
                    # por si el tag está partido entre chunks
                    buffer = buffer[-(len(TAG_OPEN) - 1):]
                    break

                fin = buffer.find(TAG_CLOSE, inicio)
                if fin == -1:
                    # Bloque aún incompleto; esperar más datos
                    break

                fin += len(TAG_CLOSE)
                bloque = buffer[inicio:fin]
                buffer = buffer[fin:]

                total_procesadas += 1

                # Determinar si pertenece a alguna de nuestras categorías
                m = re_maincat.search(bloque)
                if m:
                    cat_bloque = m.group(1).strip()
                    if cat_bloque in TODAS_VARIANTES:
                        # Averiguar a qué grupo pertenece
                        for grupo, variantes in CATEGORIAS_VARIANTES.items():
                            if cat_bloque in variantes:
                                conteos_por_cat[grupo] += 1
                                break

                        f_out.write(bloque)
                        f_out.write("\n")
                        total_escritas += 1

            # Mostrar progreso cada ~200 MB
            if bytes_procesados % (200 * 1024 * 1024) < CHUNK:
                pct     = bytes_procesados * 100 / file_size
                elapsed = time.time() - t_inicio
                eta     = (elapsed / max(pct, 0.01)) * (100 - pct)
                print(
                    f"  ⏳ {pct:5.1f}% | "
                    f"Procesadas: {total_procesadas:,} | "
                    f"Escritas: {total_escritas:,} | "
                    f"ETA: {eta/60:.1f} min"
                )

            if not dato:   # fin de archivo
                break

        # Cierre del XML de salida
        f_out.write('</yahooAnswers>\n')

    # --- RESUMEN FINAL --------------------------------------------------------
    elapsed_total = time.time() - t_inicio
    out_size      = XML_OUTPUT.stat().st_size / (1024**2)

    print("\n" + "=" * 70)
    print("EXTRACCIÓN COMPLETADA")
    print("=" * 70)
    print(f"Tiempo total:       {elapsed_total/60:.1f} minutos")
    print(f"Preguntas totales procesadas: {total_procesadas:,}")
    print(f"Preguntas escritas (4 cats):  {total_escritas:,}")
    print(f"Tamaño del XML de salida:     {out_size:.1f} MB")
    print()
    print("Desglose por categoría:")
    print("-" * 70)
    for cat, count in conteos_por_cat.items():
        pct = count * 100 / max(total_escritas, 1)
        print(f"  {cat:<35} → {count:>8,}  ({pct:.1f}%)")
    print("-" * 70)
    print(f"  {'TOTAL':<35} → {total_escritas:>8,}")
    print()
    print(f"XML filtrado guardado en:\n   {XML_OUTPUT}")
    print("=" * 70)
    print("\nSIGUIENTE PASO: Instala BaseX y carga este XML.")
    print("Descarga: https://basex.org/download/")


if __name__ == "__main__":
    extraer_categorias()
