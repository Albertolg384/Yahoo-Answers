#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera yahoo_muestra.xml — XML de muestra representativa para el XSLT.

Estrategia de selección:
  - 6 preguntas de Science & Mathematics
  - 6 preguntas de Education & Reference
  - 4 preguntas de Social Science
  - 6 preguntas de Arts & Humanities
  Total: 22 preguntas

Criterios de diversidad:
  - Al menos 2 preguntas en idioma no inglés
  - Al menos 3 preguntas SIN vot_date (best answer elegida por el autor)
  - Al menos 3 preguntas CON vot_date (best answer elegida por votación)
  - Variedad en número de answer_item (pocas y muchas respuestas)
  - Al menos 1 pregunta sin content (solo subject)
"""

import re
import time
from pathlib import Path
from collections import defaultdict

# --- CONFIGURACIÓN ------------------------------------------------------------

INPUT  = Path(r"C:\Users\manuc\OneDrive\Escritorio\INFORMATICA\4º DE INFORMÁTICA\SEGUNDO CUATRI\BBDD_AVANZADAS\FullOct2007\yahoo_4categorias.xml")
OUTPUT = Path(r"C:\Users\manuc\OneDrive\Escritorio\XML\yahoo_muestra.xml")

# Cuántas preguntas queremos por categoría (variante inglesa)
CUOTAS = {
    "Science &amp; Mathematics":  6,
    "Education &amp; Reference":  6,
    "Social Science":             4,
    "Arts &amp; Humanities":      6,
}

# Variantes lingüísticas por grupo (para contabilizar)
GRUPOS = {
    "Science &amp; Mathematics":  ["Science &amp; Mathematics", "Ciencia y Matemáticas", "Sciences et mathématiques", "Ciências e Matemática", "Wissenschaft &amp; Mathematik"],
    "Education &amp; Reference":  ["Education &amp; Reference", "Educación", "Educación y Formación", "Educação e Referência", "Enseignement et référence", "Scuola ed educazione", "Schule &amp; Bildung"],
    "Social Science":             ["Social Science", "Ciencias Sociales", "Ciencias sociales", "Sciences sociales", "Ciências Sociais", "Sozialwissenschaft"],
    "Arts &amp; Humanities":      ["Arts &amp; Humanities", "Arte y Humanidades", "Artes e Humanidades", "Arts et sciences humaines", "Kunst &amp; Geisteswissenschaft"],
}

# Mapa variante --> clave de grupo
VARIANTE_A_GRUPO = {}
for grupo, variantes in GRUPOS.items():
    for v in variantes:
        VARIANTE_A_GRUPO[v] = grupo

RE_MAINCAT  = re.compile(r"<maincat>(.*?)</maincat>", re.DOTALL)
RE_QLANG    = re.compile(r"<qlang>(.*?)</qlang>",     re.DOTALL)
RE_VOTDATE  = re.compile(r"<vot_date>",               re.DOTALL)
RE_ANSWERS  = re.compile(r"<answer_item>",             re.DOTALL)
RE_CONTENT  = re.compile(r"<content>",                 re.DOTALL)

# Entidades HTML nominales que no son válidas en XML puro.
# Saxon las rechaza al procesar el XSLT.
# Se sustituyen por sus equivalentes numéricos Unicode.
HTML_ENTITIES = {
    "&mdash;":   "&#8212;",
    "&ndash;":   "&#8211;",
    "&nbsp;":    "&#160;",
    "&hellip;":  "&#8230;",
    "&lsquo;":   "&#8216;",
    "&rsquo;":   "&#8217;",
    "&ldquo;":   "&#8220;",
    "&rdquo;":   "&#8221;",
    "&laquo;":   "&#171;",
    "&raquo;":   "&#187;",
    "&bull;":    "&#8226;",
    "&middot;":  "&#183;",
    "&copy;":    "&#169;",
    "&reg;":     "&#174;",
    "&trade;":   "&#8482;",
    "&euro;":    "&#8364;",
    "&pound;":   "&#163;",
    "&yen;":     "&#165;",
    "&cent;":    "&#162;",
    "&deg;":     "&#176;",
    "&plusmn;":  "&#177;",
    "&times;":   "&#215;",
    "&divide;":  "&#247;",
    "&frac12;":  "&#189;",
    "&frac14;":  "&#188;",
    "&frac34;":  "&#190;",
    "&sup2;":    "&#178;",
    "&sup3;":    "&#179;",
    "&alpha;":   "&#945;",
    "&beta;":    "&#946;",
    "&gamma;":   "&#947;",
    "&delta;":   "&#948;",
    "&pi;":      "&#960;",
    "&mu;":      "&#956;",
    "&sigma;":   "&#963;",
    "&omega;":   "&#969;",
    "&infin;":   "&#8734;",
    "&ge;":      "&#8805;",
    "&le;":      "&#8804;",
    "&ne;":      "&#8800;",
    "&asymp;":   "&#8776;",
    "&minus;":   "&#8722;",
    "&prime;":   "&#8242;",
    "&Prime;":   "&#8243;",
    "&acute;":   "&#180;",
    "&uml;":     "&#168;",
    "&cedil;":   "&#184;",
    "&szlig;":   "&#223;",
    "&auml;":    "&#228;",
    "&ouml;":    "&#246;",
    "&uuml;":    "&#252;",
    "&Auml;":    "&#196;",
    "&Ouml;":    "&#214;",
    "&Uuml;":    "&#220;",
    "&eacute;":  "&#233;",
    "&ecirc;":   "&#234;",
    "&egrave;":  "&#232;",
    "&agrave;":  "&#224;",
    "&aacute;":  "&#225;",
    "&oacute;":  "&#243;",
    "&uacute;":  "&#250;",
    "&iacute;":  "&#237;",
    "&ntilde;":  "&#241;",
    "&iquest;":  "&#191;",
    "&iexcl;":   "&#161;",
    "&aring;":   "&#229;",
    "&aelig;":   "&#230;",
    "&thorn;":   "&#254;",
    "&eth;":     "&#240;",
    "&ccedil;":  "&#231;",
}

def limpiar_entidades(bloque: str) -> str:
    """Sustituye entidades HTML nominales por sus equivalentes numéricos."""
    for nombre, numerico in HTML_ENTITIES.items():
        bloque = bloque.replace(nombre, numerico)
    return bloque

TAG_OPEN  = "<vespaadd>"
TAG_CLOSE = "</vespaadd>"

# --- ESTADO DE SELECCIÓN ------------------------------------------------------

seleccionados = defaultdict(list)   # grupo --> lista de bloques
stats = {
    "con_vot_date": 0,
    "sin_vot_date": 0,
    "no_english":   0,
    "sin_content":  0,
}

def grupo_lleno(grupo):
    return len(seleccionados[grupo]) >= CUOTAS.get(grupo, 0)

def todos_llenos():
    return all(grupo_lleno(g) for g in CUOTAS)

def quiero_este(bloque, grupo):
    """Criterios de diversidad para aceptar o rechazar un bloque."""
    tiene_vot = bool(RE_VOTDATE.search(bloque))
    lang_m    = RE_QLANG.search(bloque)
    lang      = lang_m.group(1).strip() if lang_m else "en"
    n_ans     = len(RE_ANSWERS.findall(bloque))
    sin_cont  = not bool(RE_CONTENT.search(bloque))

    ya_hay = seleccionados[grupo]
    n_ya   = len(ya_hay)
    cuota  = CUOTAS[grupo]

    # Si queda una sola plaza y no tenemos ninguna sin content, preferir esa.
    if n_ya == cuota - 1 and stats["sin_content"] == 0 and sin_cont:
        return True

    # Favorecer no-inglés si llevamos menos de 2 en total.
    if lang != "en" and stats["no_english"] < 2:
        return True

    # Favorecer con vot_date si llevamos menos de 3.
    if tiene_vot and stats["con_vot_date"] < 3:
        return True

    # Favorecer sin vot_date si llevamos menos de 3.
    if not tiene_vot and stats["sin_vot_date"] < 3:
        return True

    # Favorecer preguntas con muchas respuestas (>5) para variedad visual.
    if n_ans > 5 and n_ya < cuota // 2:
        return True

    # Aceptar si aún hay plazas libres (criterio de relleno).
    if n_ya < cuota:
        return True

    return False

# --- LECTURA DEL XML ----------------------------------------------------------

print("=" * 65)
print("GENERANDO XML DE MUESTRA PARA XSLT")
print("=" * 65)
print(f"Entrada: {INPUT}")
print(f"Salida:  {OUTPUT}\n")

t0 = time.time()
buffer = ""
CHUNK  = 2 * 1024 * 1024
procesadas = 0

with INPUT.open("r", encoding="utf-8", errors="ignore") as f:
    while not todos_llenos():
        dato = f.read(CHUNK)
        if not dato:
            break
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
            procesadas += 1

            m = RE_MAINCAT.search(bloque)
            if not m:
                continue
            cat_val = m.group(1).strip()
            grupo   = VARIANTE_A_GRUPO.get(cat_val)
            if not grupo or grupo_lleno(grupo):
                continue

            if quiero_este(bloque, grupo):
                seleccionados[grupo].append(bloque)

                # Actualizar stats
                if RE_VOTDATE.search(bloque):
                    stats["con_vot_date"] += 1
                else:
                    stats["sin_vot_date"] += 1

                lang_m = RE_QLANG.search(bloque)
                if lang_m and lang_m.group(1).strip() != "en":
                    stats["no_english"] += 1

                if not RE_CONTENT.search(bloque):
                    stats["sin_content"] += 1

                total = sum(len(v) for v in seleccionados.values())
                print(f"  [{total:2d}/22] {grupo[:35]:35s} — "
                      f"{len(seleccionados[grupo])}/{CUOTAS[grupo]}")

# --- ESCRITURA DEL XML DE SALIDA ----------------------------------------------

OUTPUT.parent.mkdir(parents=True, exist_ok=True)
total_final = sum(len(v) for v in seleccionados.values())

with OUTPUT.open("w", encoding="utf-8") as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    f.write(f'<!-- Muestra representativa: {total_final} preguntas -->\n')
    f.write('<yahooAnswers>\n')
    for grupo in CUOTAS:
        for bloque in seleccionados[grupo]:
            f.write(limpiar_entidades(bloque) + "\n")
    f.write('</yahooAnswers>\n')

elapsed = time.time() - t0
print(f"\nXML de muestra generado en {elapsed:.1f}s")
print(f"Total preguntas:   {total_final}")
print(f"Con vot_date:      {stats['con_vot_date']}")
print(f"Sin vot_date:      {stats['sin_vot_date']}")
print(f"En idioma no-EN:   {stats['no_english']}")
print(f"Sin campo content: {stats['sin_content']}")
print(f"\nGuardado en: {OUTPUT}")
print("\nSiguiente paso: aplica el XSLT sobre yahoo_muestra.xml en BaseX.")
