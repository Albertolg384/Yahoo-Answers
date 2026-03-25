# 📚 Yahoo Answers — Análisis XML con BaseX, XQuery y XSLT

Proyecto de análisis del dataset **Yahoo! Answers FullOct2007** (~4,4 millones de preguntas, 11 GB en XML) usando tecnologías XML: **BaseX**, **XQuery**, **XSD** y **XSLT**.

> **Autores:** Alberto Lillo García y Manuel Caballero Bonilla  
> **Asignatura:** Bases de Datos Avanzadas — 4º  Ingeniería Informática

---

## 📁 Estructura del proyecto

```
Yahoo-Answers-main/
├── Proyecto/
│   ├── Scripts Investigación Inicial y Extracción/
│   │   ├── extract_maincats.py          # Extrae categorías principales del XML
│   │   ├── extract_subcats.py           # Extrae subcategorías del XML
│   │   ├── analisis_profundo.py         # Análisis detallado de categorías
│   │   ├── analizar_categorias.py       # Cuenta ocurrencias por categoría
│   │   ├── analizar_distribucion_general.py  # Análisis global del dataset
│   │   ├── extraer_categorias.py        # Extrae las 4 categorías a un XML
│   │   ├── extraer_directo_4archivos.py # Extrae directo a 4 XMLs separados
│   │   ├── dividir_por_categoria.py     # Divide XML filtrado en 4 archivos
│   │   └── validate_extract.py          # Valida la integridad de la extracción
│   ├── Webscope_L6-1/
│   │   ├── README.txt                   # Descripción oficial del dataset
│   │   ├── WebscopeReadMe.txt           # Términos de uso Yahoo! Webscope
│   │   └── small_sample.xml             # Muestra mínima del formato XML
│   ├── XQUERY/
│   │   ├── xquery_bloque1.xq            # Estadísticas generales por categoría
│   │   ├── xquery_bloque2.xq            # Análisis de redes sociales
│   │   ├── xquery_bloque3.xq            # Análisis cross-categoría
│   │   ├── xquery_bloque4.xq            # Calidad de datos y anomalías
│   │   ├── xquery_bloque5a.xq           # Evolución temporal (fechas)
│   │   ├── xquery_bloque5b.xq           # Tiempo de resolución
│   │   └── yahoo_presentacion.html      # Presentación HTML de resultados XQuery
│   ├── XSD/
│   │   ├── yahoo_answers_original.xsd   # Esquema XSD del dataset original
│   │   ├── yahoo_answers_propuesto.xsd  # Esquema XSD mejorado/propuesto
│   │   └── verificacion_estructural.xq  # XQuery de verificación estructural
│   └── XSLT/
│       ├── yahoo_answers.xslt           # Hoja de transformación XSLT → HTML
│       ├── yahoo_muestra.xml            # Muestra de 22 preguntas para XSLT
│       ├── yahoo_resultado.html         # HTML resultante de aplicar el XSLT
│       ├── generar_muestra_xslt.py      # Genera yahoo_muestra.xml
│       └── aplicar_xslt.py             # Aplica el XSLT y genera el HTML
└── Documentación/
    ├── Caballero_Lillo_XML - Trabajo.pdf
    ├── Caballero_Lillo_XML - Presentacion.pdf
    └── Caballero_Lillo_XML - LabBook.pdf
```

---

## 🔧 Requisitos previos

### Dataset (obligatorio para todos)

El dataset **no está incluido** en el repositorio (11 GB descomprimido). Debes obtenerlo aquí: [Yahoo! 2007](https://pruebasaluuclm-my.sharepoint.com/:u:/g/personal/alberto_lillo1_alu_uclm_es/IQCXHGDdS4srQJnLyqQjB6BcAUcieW7mt4yjDMXBSD4A7Ws?e=08pRp3) .


---

## 🐧 Instalación en Ubuntu / Linux

### 1. Requisitos del sistema

```bash
sudo apt update
sudo apt install -y python3 python3-pip default-jdk unzip
```

Verifica las versiones:
```bash
python3 --version   # Se requiere Python 3.6+
java -version       # Se requiere Java 11+
```

### 2. Dependencias Python

```bash
pip3 install lxml
```

> ⚠️ **Aviso:** El archivo resultante pesa ~11 GB. Asegúrate de tener al menos **15 GB** libres en disco.

### 3. Instalar BaseX

```bash
# Descargar BaseX
wget https://files.basex.org/releases/10.7/BaseX107.zip
unzip BaseX107.zip -d ~/basex
```

Arranca la interfaz gráfica de BaseX:
```bash
~/basex/bin/basexgui
```

---

## Instalación en Windows

### 1. Python

1. Descarga Python 3.x desde [python.org](https://www.python.org/downloads/)
2. Durante la instalación, marca **"Add Python to PATH"**
3. Verifica en CMD o PowerShell:

```cmd
python --version
pip --version
```

### 2. Dependencias Python

Abre **CMD** o **PowerShell** y ejecuta:

```cmd
pip install lxml
```

> ⚠️ **Aviso:** El archivo resultante pesa ~11 GB. Asegúrate de tener al menos **15 GB** libres en disco.

### 3. Instalar Java

BaseX requiere Java. Descarga el **JDK 11 o superior** desde [adoptium.net](https://adoptium.net/) e instálalo.

Verifica en CMD:
```cmd
java -version
```

### 4. Instalar BaseX

1. Descarga el instalador `.exe` desde [basex.org/download](https://basex.org/download/)
2. Ejecuta el instalador y sigue los pasos
3. Abre **BaseX GUI** desde el menú Inicio

---

## ▶️ Ejecución paso a paso

### FASE 1 — Exploración inicial del dataset

> **Nota:** Estos scripts procesan el XML de 11 GB eficientemente por chunks. No saturan la memoria RAM. Cada uno tarda entre 5 y 20 minutos.

Antes de ejecutar, edita la variable `INPUT` al principio de cada script para apuntar a tu archivo `FullOct2007.xml`.

**Ubuntu:**
```bash
cd "Proyecto/Scripts Investigación Inicial y Extracción"

python3 extract_maincats.py         # Obtiene lista de categorías principales
python3 extract_subcats.py          # Obtiene lista de subcategorías
python3 analisis_profundo.py        # Analiza y recomienda combinaciones
```

**Windows (CMD):**
```cmd
cd "Proyecto\Scripts Investigación Inicial y Extracción"

python extract_maincats.py
python extract_subcats.py
python analisis_profundo.py
```

**Salida esperada:**
- `FullOct2007.maincats.txt` — lista de categorías únicas
- `FullOct2007.subcats.txt` — lista de subcategorías únicas
- Estadísticas por consola con recomendaciones de categorías

---

### FASE 2 — Extracción y validación

Estos scripts filtran el dataset completo y extraen las **4 categorías** seleccionadas:
- `Science & Mathematics`
- `Education & Reference`
- `Social Science`
- `Arts & Humanities`

**Ubuntu:**
```bash
# Opción A: extrae todo en un archivo (1,5 GB) y luego divide
python3 extraer_categorias.py       # ~80 min — genera yahoo_4categorias.xml
python3 dividir_por_categoria.py    # ~10 min — genera 4 XMLs por categoría

# Opción B: extrae y divide directamente (sin archivo intermedio)
python3 extraer_directo_4archivos.py  # ~70 min

# Validación
python3 analizar_categorias.py      # Cuenta preguntas (debe ser 613.245)
python3 analizar_distribucion_general.py  # Análisis global completo
python3 validate_extract.py         # Verifica integridad de la extracción
```

**Windows:**
```cmd
python extraer_categorias.py
python dividir_por_categoria.py
python analizar_categorias.py
python analizar_distribucion_general.py
python validate_extract.py
```

**Salida esperada:**
- `yahoo_4categorias.xml` (~1,5 GB) si usas la Opción A
- `yahoo_science.xml`, `yahoo_education.xml`, `yahoo_social.xml`, `yahoo_arts.xml`
- Conteo total: **613.245 preguntas** repartidas entre las 4 categorías

---

### FASE 3 — Carga en BaseX

Abre la **interfaz gráfica de BaseX** (BaseX GUI) y crea una base de datos con los XML extraídos.

#### Desde la GUI de BaseX:

1. Ve a **Database → New…**
2. Nombre de la base de datos: `yahoo_answers`
3. Añade los 4 archivos XML (o el combinado `yahoo_4categorias.xml`)
4. Haz clic en **OK** para iniciar la indexación

> ⚠️ La indexación puede tardar varios minutos dependiendo del tamaño del XML.

#### Alternativa por línea de comandos:

**Ubuntu:**
```bash
~/basex/bin/basex -c "CREATE DB yahoo_answers /ruta/a/yahoo_science.xml"
~/basex/bin/basex -c "ADD TO yahoo_answers /ruta/a/yahoo_education.xml"
~/basex/bin/basex -c "ADD TO yahoo_answers /ruta/a/yahoo_social.xml"
~/basex/bin/basex -c "ADD TO yahoo_answers /ruta/a/yahoo_arts.xml"
```

**Windows (CMD):**
```cmd
"C:\Program Files (x86)\BaseX\bin\basex.bat" -c "CREATE DB yahoo_answers C:\ruta\yahoo_science.xml"
"C:\Program Files (x86)\BaseX\bin\basex.bat" -c "ADD TO yahoo_answers C:\ruta\yahoo_education.xml"
```

---

### FASE 4 — Ejecutar consultas XQuery

Abre la **BaseX GUI**, conecta a la base de datos `yahoo_answers` y carga cada bloque XQuery desde **Editor → Open…**

| Archivo | Contenido |
|---|---|
| `xquery_bloque1.xq` | Estadísticas generales y perfil por categoría |
| `xquery_bloque2.xq` | Análisis de redes sociales entre usuarios |
| `xquery_bloque3.xq` | Análisis cross-categoría y subcategorías |
| `xquery_bloque4.xq` | Calidad de datos y detección de anomalías |
| `xquery_bloque5a.xq` | Evolución temporal de preguntas por fecha |
| `xquery_bloque5b.xq` | Tiempo medio de resolución de preguntas |

Para ejecutar un bloque:
1. Abre el archivo `.xq` en el editor de BaseX
2. Pulsa **F5** o el botón **Run** (▶)
3. El resultado aparece en el panel inferior

También puedes visualizar los resultados en formato HTML abriendo `yahoo_presentacion.html` directamente en el navegador.

---

### FASE 5 — Validación XSD

Los esquemas XSD describen la estructura del dataset. Puedes validarlos desde BaseX:

**En BaseX GUI (Editor):**
```xquery
(: Validar el XML de muestra contra el XSD propuesto :)
validate:xsd(doc("yahoo_muestra.xml"), doc("yahoo_answers_propuesto.xsd"))
```

O ejecuta el script de verificación estructural:
1. Abre `XSD/verificacion_estructural.xq` en el editor de BaseX
2. Ejecuta con **F5**

---

### FASE 6 — Generación y visualización XSLT

Esta fase genera una visualización HTML a partir de una muestra representativa de 22 preguntas.

#### Paso 6.1 — Editar las rutas en los scripts

Abre `XSLT/generar_muestra_xslt.py` y edita la variable `INPUT` para apuntar a tu archivo `yahoo_4categorias.xml`:

**Windows:**
```python
INPUT  = Path(r"C:\ruta\a\yahoo_4categorias.xml")
OUTPUT = Path(r"C:\ruta\a\XSLT\yahoo_muestra.xml")
```

**Ubuntu:**
```python
INPUT  = Path("/ruta/a/yahoo_4categorias.xml")
OUTPUT = Path("/ruta/a/XSLT/yahoo_muestra.xml")
```

Haz lo mismo en `XSLT/aplicar_xslt.py` con las variables `XML_FILE`, `XSLT_FILE` y `HTML_OUT`.

#### Paso 6.2 — Generar el XML de muestra

**Ubuntu:**
```bash
cd Proyecto/XSLT
python3 generar_muestra_xslt.py
```

**Windows:**
```cmd
cd Proyecto\XSLT
python generar_muestra_xslt.py
```

**Salida esperada:** `yahoo_muestra.xml` con 22 preguntas representativas de las 4 categorías.

#### Paso 6.3 — Aplicar la transformación XSLT

**Ubuntu:**
```bash
python3 aplicar_xslt.py
```

**Windows:**
```cmd
python aplicar_xslt.py
```

**Salida esperada:** `yahoo_resultado.html` — página HTML completamente formateada con las preguntas y respuestas.

#### Paso 6.4 — Visualizar el resultado

Abre el archivo `yahoo_resultado.html` en cualquier navegador web (Chrome, Firefox, Edge…):

**Ubuntu:**
```bash
xdg-open Proyecto/XSLT/yahoo_resultado.html
```

**Windows:**
```cmd
start Proyecto\XSLT\yahoo_resultado.html
```

> 💡 También puedes abrir directamente el archivo `yahoo_resultado.html` ya incluido en el repositorio para ver un ejemplo del resultado final sin ejecutar nada.

---

## 📋 Resumen de comandos — orden de ejecución recomendado

```
1. Reconstruir FullOct2007.xml desde los .gz
2. python extract_maincats.py
3. python extract_subcats.py
4. python analisis_profundo.py
5. python extraer_categorias.py          ~80 min
6. python dividir_por_categoria.py       ~10 min
7. python analizar_categorias.py         validación (debe dar 613.245)
8. python validate_extract.py            verificación de integridad
9. Cargar XMLs en BaseX (base de datos: yahoo_answers)
10. Ejecutar xquery_bloque1.xq ... xquery_bloque5b.xq en BaseX
11. python generar_muestra_xslt.py
12. python aplicar_xslt.py
13. Abrir yahoo_resultado.html en el navegador
```

---

## ⚠️ Notas importantes

- **El dataset NO está incluido** en el repositorio. Debes obtenerlo a través del link.
- El XML completo pesa **11 GB** descomprimido. Necesitas al menos 15 GB libres para tener el XML original, los archivos intermedios y la base de datos de BaseX.
- Los scripts de extracción procesan el XML en chunks de 2 MB para mantener el uso de RAM bajo (~50 MB máximo).
- Los tiempos de proceso indicados corresponden a un equipo de gama media. En SSDs modernos pueden reducirse a la mitad.
- Los archivos `yahoo_muestra.xml` y `yahoo_resultado.html` ya están incluidos en el repositorio como ejemplo del resultado final.

---

## 📦 Dependencias resumidas

| Herramienta | Versión mínima | Uso |
|---|---|---|
| Python | 3.6+ | Scripts de extracción y XSLT |
| lxml | cualquiera | Transformación XSLT en Python |
| Java (JDK) | 11+ | Necesario para ejecutar BaseX |
| BaseX | 10.x | Base de datos XML y motor XQuery |

---

## 📄 Licencia del dataset

El dataset Yahoo! Answers es propiedad de Yahoo! y está sujeto a los términos del programa **Yahoo! Webscope**. Su uso está restringido a fines de investigación académica no comercial bajo acuerdo firmado. Consulta `Proyecto/Webscope_L6-1/WebscopeReadMe.txt` para los términos completos.
