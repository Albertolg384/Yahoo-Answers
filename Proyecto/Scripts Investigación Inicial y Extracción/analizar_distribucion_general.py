#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Verificar si hay duplicados o inconsistencias en los conteos de categorías
"""

import re
import os

XML_FILE = r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\FullOct2007.xml"

print("=" * 80)
print("VERIFICACIÓN DE INTEGRIDAD - DUPLICADOS Y CONSISTENCIA")
print("=" * 80 + "\n")

# Compilar regex para maincat
patron = re.compile(r"<maincat>(.*?)</maincat>", re.DOTALL)

# Lista para almacenar TODAS las categorías (con posibles duplicados)
todas_categorias = []
categorias_unicas = set()

chunk_size = 1024 * 1024  # 1MB chunks

try:
    file_size = os.path.getsize(XML_FILE)
    print(f"Tamaño del archivo: {file_size / (1024*1024):.1f} MB\n")
    
    with open(XML_FILE, 'r', encoding='utf-8', errors='ignore') as f:
        buffer = ""
        bytes_processed = 0
        contador_matches = 0
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

                match = patron.search(bloque)
                if match:
                    categoria = match.group(1).strip()
                    todas_categorias.append(categoria)
                    categorias_unicas.add(categoria)
                    contador_matches += 1
            
            # Mostrar progreso
            if bytes_processed % (50 * 1024 * 1024) == 0:
                print(f"Procesados: {bytes_processed / (1024*1024):.1f} MB")
    
    print("\n" + "=" * 80)
    print("ANÁLISIS")
    print("=" * 80 + "\n")
    
    print(f"Total de etiquetas <maincat> encontradas: {len(todas_categorias):,}")
    print(f"Categorías ÚNICAS: {len(categorias_unicas):,}\n")
    
    # Verificar si hay duplicados
    if len(todas_categorias) == len(categorias_unicas):
        print("NO HAY DUPLICADOS: Cada etiqueta es única\n")
    else:
        print(f"DUPLICADOS ENCONTRADOS: {len(todas_categorias) - len(categorias_unicas):,} repeticiones\n")
    
    # Mostrar distribución
    from collections import Counter
    distribucion = Counter(todas_categorias)
    
    print("Top 10 Categorías más frecuentes:")
    print("-" * 80)
    for i, (cat, count) in enumerate(distribucion.most_common(10), 1):
        print(f"{i:2d}. {cat[:60]:60s} → {count:,} ocurrencias")
    
    print("\n" + "=" * 80)
    
    # Comparación con nuestros conteos
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
    
    total_4_cats = 0
    print("VERIFICACIÓN DE CONTEOS (4 categorías principales con TODAS las variantes lingüísticas):")
    print("-" * 80)
    for grupo, variantes in CATEGORIAS_VARIANTES.items():
        count_grupo = 0
        variantes_encontradas = []
        for variante in variantes:
            count = distribucion.get(variante, 0)
            if count > 0:
                count_grupo += count
                variantes_encontradas.append(f"{variante} ({count:,})")
        
        total_4_cats += count_grupo
        print(f"{grupo[:15]:15s} → {count_grupo:,} total")
        if variantes_encontradas:
            print(f"└─ Variantes: {', '.join(variantes_encontradas)}")
    
    print("-" * 80)
    print(f"Total de 4 categorías: {total_4_cats:,}")
    print(f"Porcentaje del total: {total_4_cats/len(todas_categorias)*100:.2f}%")
    
    print("\n" + "=" * 80)
    print(f"VERIFICACIÓN COMPLETADA: {len(todas_categorias):,} preguntas procesadas sin error")
    
except Exception as e:
    print(f"Error: {e}")
