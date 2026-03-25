# README - Scripts de Análisis Yahoo Answers FullOct2007
# Proyecto: Dataset Yahoo Answers
# Fecha: Marzo 2026

Este documento describe brevemente cada script Python utilizado en el procesamiento
y análisis del dataset Yahoo Answers FullOct2007 (11 GB XML con ~4.4M preguntas).

Los scripts están organizados por fases: exploración inicial, extracción, análisis
y preparación para BaseX/XQuery.

===============================================================================

## 1. SCRIPTS DE EXPLORACIÓN INICIAL

### extract_maincats.py
**Propósito**: Extraer todas las categorías principales únicas del XML completo.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: FullOct2007.maincats.txt (lista de categorías únicas)
**Lógica**: Lee línea por línea, busca <maincat> con regex, almacena en set.
**Notas**: Primer script ejecutado para entender la estructura del dataset.

### extract_subcats.py
**Propósito**: Extraer todas las subcategorías únicas del XML completo.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: FullOct2007.subcats.txt (lista de subcategorías únicas)
**Lógica**: Procesa en chunks de 1MB, busca <subcat> con regex, evita duplicados.
**Notas**: Complementa extract_maincats.py para análisis de jerarquía.

### analisis_profundo.py
**Propósito**: Análisis detallado de categorías y subcategorías.
**Entrada**: FullOct2007.maincats.txt y FullOct2007.subcats.txt
**Salida**: Output por consola (estadísticas y recomendaciones)
**Lógica**: Filtra categorías libres, busca subcategorías relacionadas con temas científicos/educativos.
**Notas**: Recomienda combinaciones óptimas de categorías.

===============================================================================

## 2. SCRIPTS DE EXTRACCIÓN Y FILTRADO

### extraer_categorias.py
**Propósito**: Extraer preguntas de las 4 categorías seleccionadas (Science, Education, Social, Arts) con todas sus variantes lingüísticas.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: yahoo_4categorias.xml (1.5 GB, 613,245 preguntas filtradas)
**Lógica**: Procesa bloques <vespaadd>...</vespaadd> completos, busca <maincat>, filtra por variantes, escribe XML válido.
**Tiempo**: ~80 minutos
**Notas**: Script maestro de extracción. Maneja variantes multilingües. Evita doble conteo procesando bloques enteros.

### extraer_directo_4archivos.py
**Propósito**: Extraer directamente del XML original (11 GB) y dividir en 4 archivos XML separados por categoría.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: yahoo_science.xml, yahoo_education.xml, yahoo_social.xml, yahoo_arts.xml
**Lógica**: Similar a extraer_categorias.py pero escribe en archivos separados por categoría desde el inicio.
**Tiempo**: ~60-80 minutos
**Notas**: Alternativa al script anterior. Útil si no se quiere el archivo intermedio de 1.5 GB.

### dividir_por_categoria.py
**Propósito**: Dividir el XML filtrado (yahoo_4categorias.xml) en 4 archivos separados por categoría.
**Entrada**: yahoo_4categorias.xml (1.5 GB)
**Salida**: yahoo_science.xml, yahoo_education.xml, yahoo_social.xml, yahoo_arts.xml
**Lógica**: Lee el XML filtrado, reparsea bloques, distribuye por categoría.
**Tiempo**: ~5-10 minutos
**Notas**: Paso posterior a extraer_categorias.py. Facilita carga en BaseX por separado.

===============================================================================

## 3. SCRIPTS DE ANÁLISIS Y VALIDACIÓN

### analizar_categorias.py
**Propósito**: Contar ocurrencias de las 4 categorías seleccionadas en el XML completo.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: Output por consola (conteos por categoría, porcentajes, total)
**Lógica**: Procesa bloques <vespaadd> completos, busca <maincat>, cuenta por grupo de variantes.
**Notas**: Versión "ligera" de extraer_categorias.py sin extracción. Valida consistencia (debe dar 613,245).

### analizar_distribucion_general.py
**Propósito**: Análisis exhaustivo del dataset completo + verificación de las 4 categorías.
**Entrada**: FullOct2007.xml (11 GB)
**Salida**: Output por consola (estadísticas globales, top 10 categorías, verificación 4 cats)
**Notas**: Análisis exploratorio completo. Confirma que las 4 categorías suman 613,245 del total.

### validate_extract.py
**Propósito**: Validar que la extracción de categorías fue completa y correcta.
**Entrada**: FullOct2007.xml (11 GB) + FullOct2007.maincats.txt (opcional)
**Salida**: Output por consola (estadísticas de validación, diferencias si las hay)
**Lógica**: Reescanea el XML completo, compara categorías extraídas vs encontradas.
**Notas**: Script de calidad. Asegura integridad de la extracción.

===============================================================================

## DEPENDENCIAS COMUNES
- Python 3.6+
- Librerías estándar: re, os, time, pathlib, collections
- Sistema: Windows/Linux/Mac (adaptable)
- Memoria: Suficiente para procesar chunks de 2MB (baja huella)

## ORDEN DE EJECUCIÓN RECOMENDADO
1. extract_maincats.py
2. extract_subcats.py
3. validate_extract.py (verificación final)
4. analisis_profundo.py (para decidir categorías)
5. analizar_categorias.py (validación)
6. analizar_distribucion_general.py (análisis completo)
7. extraer_categorias.py (o extraer_directo_4archivos.py)
8. dividir_por_categoria.py (si se necesita)
9. Instalar BaseX y cargar XMLs

## NOTAS GENERALES
- Todos los scripts procesan XML de 11GB eficientemente usando chunks y búsqueda de strings.
- Evitan parsers XML completos para no saturar memoria.
- Manejan variantes lingüísticas de categorías (inglés, español, francés, portugués, alemán, italiano).
- Los conteos deben coincidir en 613,245 para las 4 categorías.
- Preparados para integración con BaseX/XQuery/XSD para el trabajo.

===============================================================================