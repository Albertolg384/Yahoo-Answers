#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Aplica el XSLT sobre yahoo_muestra.xml y genera yahoo_resultado.html
usando la librería lxml, sin depender de BaseX para la transformación.

Requiere: pip install lxml
"""

from lxml import etree
from pathlib import Path

# --- RUTAS --------------------------------------------------------------------

BASE = Path(r"C:\Users\manuc\OneDrive\Escritorio\XML")

XML_FILE  = BASE / "yahoo_muestra.xml"
XSLT_FILE = BASE / "yahoo_answers.xslt"
HTML_OUT  = BASE / "yahoo_resultado.html"

# --- TRANSFORMACIÓN -----------------------------------------------------------

print("=" * 55)
print("APLICANDO XSLT → HTML")
print("=" * 55)
print(f"XML:   {XML_FILE}")
print(f"XSLT:  {XSLT_FILE}")
print(f"HTML:  {HTML_OUT}")
print()

# Cargar XML.
xml_doc = etree.parse(str(XML_FILE))
print("XML cargado correctamente")

# Cargar XSLT.
xslt_doc = etree.parse(str(XSLT_FILE))
transform = etree.XSLT(xslt_doc)
print("XSLT cargado correctamente")

# Aplicar transformación.
result = transform(xml_doc)
print("Transformación completada")

# Escribir HTML con DOCTYPE correcto.
html_bytes = etree.tostring(
    result,
    pretty_print=True,
    method="html",
    encoding="UTF-8",
    doctype="<!DOCTYPE html>"
)

HTML_OUT.write_bytes(html_bytes)
print(f"HTML guardado en: {HTML_OUT}")
print(f"Tamaño: {HTML_OUT.stat().st_size / 1024:.1f} KB")
print()
print("Abre yahoo_resultado.html en el navegador.")
