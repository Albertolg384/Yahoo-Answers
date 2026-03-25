#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Contar ocurrencias de categorías principales específicas en Yahoo Answers XML
"""

import re
import os

# Categorías a buscar (con caracteres HTML encodeados)
CATEGORIAS_BUSCAR = [
    "Science &amp; Mathematics",
    "Education &amp; Reference",
    "Social Science",
    "Arts &amp; Humanities"
]

# Variantes multilingües de las categorías principales
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
# Ruta del archivo XML
XML_FILE = r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\FullOct2007.xml"

print("=" * 80)
print("CONTANDO OCURRENCIAS DE CATEGORÍAS")
print("=" * 80)
print(f"\nArchivo: {XML_FILE}")
print(f"Buscando {len(CATEGORIAS_BUSCAR)} categorías...\n")

# Compilar regex para maincat dentro de cada bloque de pregunta
re_maincat = re.compile(r"<maincat>(.*?)</maincat>", re.DOTALL)

# Diccionario para almacenar conteos por grupo
conteos = {grupo: 0 for grupo in CATEGORIAS_VARIANTES}

# Leer archivo en chunks
chunk_size = 1024 * 1024  # 1MB chunks
total_lineas = 0

try:
    file_size = os.path.getsize(XML_FILE)
    print(f"Tamaño del archivo: {file_size / (1024*1024):.1f} MB\n")
    
    with open(XML_FILE, 'r', encoding='utf-8', errors='ignore') as f:
        buffer = ""
        bytes_processed = 0
        tag_open = "<vespaadd>"
        tag_close = "</vespaadd>"
        
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            
            buffer += chunk
            bytes_processed += len(chunk)
            
            # Procesar bloques completos para evitar conteos duplicados por solape
            while True:
                inicio = buffer.find(tag_open)
                if inicio == -1:
                    buffer = buffer[-(len(tag_open) - 1):]
                    break

                fin = buffer.find(tag_close, inicio)
                if fin == -1:
                    break

                fin += len(tag_close)
                bloque = buffer[inicio:fin]
                buffer = buffer[fin:]

                match = re_maincat.search(bloque)
                if match:
                    categoria = match.group(1).strip()
                    for grupo, variantes in CATEGORIAS_VARIANTES.items():
                        if categoria in variantes:
                            conteos[grupo] += 1
            
            # Mostrar progreso cada 50MB
            if bytes_processed % (50 * 1024 * 1024) == 0:
                print(f"Procesados: {bytes_processed / (1024*1024):.1f} MB ({bytes_processed*100//file_size}%)")
    
    print("\n" + "=" * 80)
    print("RESULTADOS")
    print("=" * 80 + "\n")
    total_encontradas = sum(conteos.values())
    for grupo in CATEGORIAS_VARIANTES:
        ocurrencias = conteos[grupo]
        porcentaje = (ocurrencias / total_encontradas * 100) if total_encontradas > 0 else 0
        print(f"{grupo}")
        print(f"└─ Ocurrencias: {ocurrencias:,}")
        print(f"└─ Porcentaje: {porcentaje:.2f}%\n")
    print("=" * 80)
    print(f"TOTAL ENCONTRADAS: {total_encontradas:,} ocurrencias\n")
    
except FileNotFoundError:
    print(f"Error: Archivo no encontrado: {XML_FILE}")
except Exception as e:
    print(f"Error: {e}")
