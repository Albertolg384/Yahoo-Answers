<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- ============================================================
       TEMPLATE RAIZ
  ============================================================ -->
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"></meta>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"></meta>
        <title>Yahoo! Answers &#8212; Knowledge Archive 2007</title>
        <style>
          *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
          :root{
            --bg:#f4f6fb;
            --white:#ffffff;
            --surface:#f9fafd;
            --border:#e2e8f0;
            --text:#1a202c;
            --muted:#718096;
            --light:#edf2f7;
            --sci:#0077cc;
            --sci-light:#e6f2ff;
            --edu:#00875a;
            --edu-light:#e3fcef;
            --soc:#c05621;
            --soc-light:#fff5eb;
            --art:#6b46c1;
            --art-light:#faf5ff;
            --gold:#b7791f;
            --gold-light:#fffbeb;
            --radius:12px;
            --shadow:0 1px 3px rgba(0,0,0,.08), 0 4px 12px rgba(0,0,0,.04);
            --shadow-hover:0 4px 12px rgba(0,0,0,.12), 0 8px 24px rgba(0,0,0,.06);
            --font-body:-apple-system,BlinkMacSystemFont,'Segoe UI',system-ui,sans-serif;
            --font-mono:'SFMono-Regular','Consolas','Courier New',monospace;
          }
          html{background:var(--bg);color:var(--text);font-family:var(--font-body);font-size:15px;line-height:1.6}
          body{min-height:100vh}

          /* CHECKBOXES OCULTOS */
          .fcb{display:none}

          /* HEADER */
          header{
            background:var(--white);
            border-bottom:1px solid var(--border);
            padding:40px 48px 32px;
            box-shadow:0 1px 3px rgba(0,0,0,.06);
          }
          .header-inner{max-width:1400px;margin:0 auto}
          .header-top{display:flex;align-items:flex-start;justify-content:space-between;flex-wrap:wrap;gap:16px;margin-bottom:32px}
          .brand{}
          .brand h1{
            font-size:1.75rem;font-weight:800;letter-spacing:-0.5px;
            color:var(--text);
          }
          .brand h1 span{color:var(--sci)}
          .brand p{font-size:.8rem;color:var(--muted);letter-spacing:1.5px;text-transform:uppercase;margin-top:3px;font-family:var(--font-mono)}
          .header-meta{
            font-family:var(--font-mono);font-size:.72rem;color:var(--muted);
            background:var(--light);padding:8px 14px;border-radius:6px;
            border:1px solid var(--border);align-self:flex-start;line-height:1.8;
          }

          /* STATS */
          .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:12px;margin-bottom:28px}
          .stat-card{
            background:var(--white);border:1px solid var(--border);
            border-radius:10px;padding:14px 16px;text-align:center;
            transition:transform .15s,box-shadow .15s;
          }
          .stat-card:hover{transform:translateY(-1px);box-shadow:var(--shadow)}
          .stat-number{font-family:var(--font-mono);font-size:1.6rem;font-weight:700;display:block;line-height:1}
          .stat-label{font-size:.65rem;color:var(--muted);text-transform:uppercase;letter-spacing:1px;margin-top:5px;display:block}
          .stat-card.sci .stat-number{color:var(--sci)}
          .stat-card.edu .stat-number{color:var(--edu)}
          .stat-card.soc .stat-number{color:var(--soc)}
          .stat-card.art .stat-number{color:var(--art)}
          .stat-card.total .stat-number{color:var(--text)}
          .stat-card.sci{border-top:3px solid var(--sci)}
          .stat-card.edu{border-top:3px solid var(--edu)}
          .stat-card.soc{border-top:3px solid var(--soc)}
          .stat-card.art{border-top:3px solid var(--art)}

          /* FILTROS */
          .filter-row{display:flex;flex-wrap:wrap;gap:8px;align-items:center}
          .filter-label-txt{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:1.5px;margin-right:4px;font-family:var(--font-mono)}
          .filter-btn{
            font-family:var(--font-mono);font-size:.72rem;letter-spacing:.5px;
            text-transform:uppercase;padding:6px 14px;border-radius:20px;
            cursor:pointer;border:1.5px solid;transition:all .2s;
            user-select:none;display:inline-block;font-weight:500;
          }
          .filter-btn.sci{color:var(--sci);border-color:var(--sci);background:var(--sci-light)}
          .filter-btn.edu{color:var(--edu);border-color:var(--edu);background:var(--edu-light)}
          .filter-btn.soc{color:var(--soc);border-color:var(--soc);background:var(--soc-light)}
          .filter-btn.art{color:var(--art);border-color:var(--art);background:var(--art-light)}
          .filter-btn:hover{opacity:.8}

          #fsci:not(:checked) ~ header .filter-btn.sci{background:var(--white);opacity:.5}
          #fedu:not(:checked) ~ header .filter-btn.edu{background:var(--white);opacity:.5}
          #fsoc:not(:checked) ~ header .filter-btn.soc{background:var(--white);opacity:.5}
          #fart:not(:checked) ~ header .filter-btn.art{background:var(--white);opacity:.5}

          /* LOGICA FILTRADO */
          #fsci:not(:checked) ~ main .card-sci{display:none}
          #fedu:not(:checked) ~ main .card-edu{display:none}
          #fsoc:not(:checked) ~ main .card-soc{display:none}
          #fart:not(:checked) ~ main .card-art{display:none}

          /* GRID */
          main{
            max-width:1400px;margin:32px auto;padding:0 48px 48px;
            display:grid;
            grid-template-columns:repeat(auto-fill,minmax(420px,1fr));
            gap:20px;
          }

          /* TARJETA */
          .card{
            background:var(--white);
            border:1px solid var(--border);
            border-radius:var(--radius);
            padding:0;
            display:flex;flex-direction:column;
            box-shadow:var(--shadow);
            transition:transform .2s,box-shadow .2s;
            overflow:hidden;
          }
          .card:hover{transform:translateY(-2px);box-shadow:var(--shadow-hover)}

          /* BARRA COLOR SUPERIOR POR CATEGORIA */
          .card-sci .card-stripe{background:var(--sci)}
          .card-edu .card-stripe{background:var(--edu)}
          .card-soc .card-stripe{background:var(--soc)}
          .card-art .card-stripe{background:var(--art)}
          .card-stripe{height:4px}

          .card-body{padding:20px;display:flex;flex-direction:column;gap:12px;flex:1}

          /* CABECERA TARJETA */
          .card-top{display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
          .badge{
            font-family:var(--font-mono);font-size:.65rem;text-transform:uppercase;
            letter-spacing:1px;padding:3px 10px;border-radius:20px;font-weight:600;
            white-space:nowrap;
          }
          .badge-sci{color:var(--sci);background:var(--sci-light);border:1px solid #bee3f8}
          .badge-edu{color:var(--edu);background:var(--edu-light);border:1px solid #c6f6d5}
          .badge-soc{color:var(--soc);background:var(--soc-light);border:1px solid #fed7aa}
          .badge-art{color:var(--art);background:var(--art-light);border:1px solid #e9d8fd}
          .lang-badge{
            font-family:var(--font-mono);font-size:.68rem;color:var(--muted);
            background:var(--light);padding:3px 8px;border-radius:4px;white-space:nowrap;
          }
          .subcat{font-family:var(--font-mono);font-size:.68rem;color:var(--muted)}
          .question{font-size:1rem;font-weight:700;color:var(--text);line-height:1.4}
          .content-text{
            font-size:.85rem;color:var(--muted);line-height:1.55;
            border-left:3px solid var(--border);padding-left:10px;
            font-style:italic;
          }

          /* MEJOR RESPUESTA */
          .best-answer{
            border-radius:8px;padding:12px 14px;
            border:1px solid;
          }
          .card-sci .best-answer{background:var(--sci-light);border-color:#bee3f8}
          .card-edu .best-answer{background:var(--edu-light);border-color:#c6f6d5}
          .card-soc .best-answer{background:var(--soc-light);border-color:#fed7aa}
          .card-art .best-answer{background:var(--art-light);border-color:#e9d8fd}
          .best-answer-label{
            font-family:var(--font-mono);font-size:.67rem;text-transform:uppercase;
            letter-spacing:1px;margin-bottom:6px;font-weight:600;
          }
          .card-sci .best-answer-label{color:var(--sci)}
          .card-edu .best-answer-label{color:var(--edu)}
          .card-soc .best-answer-label{color:var(--soc)}
          .card-art .best-answer-label{color:var(--art)}
          .best-answer-text{font-size:.84rem;color:var(--text);line-height:1.55}

          /* RESPUESTAS ALTERNATIVAS */
          details.alt{border:1px solid var(--border);border-radius:8px;overflow:hidden}
          details.alt summary{
            font-family:var(--font-mono);font-size:.72rem;color:var(--muted);
            padding:9px 13px;cursor:pointer;list-style:none;user-select:none;
            background:var(--surface);transition:background .15s;
          }
          details.alt summary::-webkit-details-marker{display:none}
          details.alt[open] summary,details.alt summary:hover{background:var(--light);color:var(--text)}
          .alt-item{
            font-size:.82rem;color:#4a5568;line-height:1.5;
            padding:9px 13px;border-top:1px solid var(--border);
          }
          .alt-n{
            font-family:var(--font-mono);font-size:.63rem;color:var(--muted);
            margin-right:6px;background:var(--light);padding:1px 5px;border-radius:3px;
          }

          /* PIE TARJETA */
          .card-footer{
            padding:12px 20px;
            border-top:1px solid var(--border);
            display:flex;justify-content:space-between;align-items:center;
            gap:8px;flex-wrap:wrap;background:var(--surface);
          }
          .dates{display:flex;flex-direction:column;gap:2px}
          .date-item{font-family:var(--font-mono);font-size:.65rem;color:var(--muted)}
          .meta-right{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
          .voted-badge{
            font-family:var(--font-mono);font-size:.63rem;color:var(--gold);
            background:var(--gold-light);border:1px solid #f6d860;
            padding:2px 8px;border-radius:4px;white-space:nowrap;font-weight:600;
          }
          .author-badge{
            font-family:var(--font-mono);font-size:.63rem;color:var(--muted);
            background:var(--light);border:1px solid var(--border);
            padding:2px 8px;border-radius:4px;white-space:nowrap;
          }
          .author-id{
            font-family:var(--font-mono);font-size:.65rem;color:var(--muted);
            background:var(--light);border:1px solid var(--border);
            padding:2px 7px;border-radius:4px;
          }
          .uri-badge{
            font-family:var(--font-mono);font-size:.62rem;color:#a0aec0;
            background:var(--light);border:1px solid var(--border);
            padding:2px 7px;border-radius:4px;
          }

          /* FOOTER GLOBAL */
          footer{
            text-align:center;padding:28px 48px;
            font-family:var(--font-mono);font-size:.68rem;color:var(--muted);
            border-top:1px solid var(--border);background:var(--white);
            letter-spacing:.5px;
          }
          ::-webkit-scrollbar{width:6px}
          ::-webkit-scrollbar-track{background:var(--bg)}
          ::-webkit-scrollbar-thumb{background:#cbd5e0;border-radius:3px}
        </style>
      </head>
      <body>

        <input type="checkbox" id="fsci" class="fcb" checked="checked"></input>
        <input type="checkbox" id="fedu" class="fcb" checked="checked"></input>
        <input type="checkbox" id="fsoc" class="fcb" checked="checked"></input>
        <input type="checkbox" id="fart" class="fcb" checked="checked"></input>

        <header>
          <div class="header-inner">
            <div class="header-top">
              <div class="brand">
                <h1>Yahoo! <span>Answers</span></h1>
                <p>Knowledge Archive &#183; October 2007 &#183; BBDD Avanzadas &#183; UCLM</p>
              </div>
              <div class="header-meta">
                Dataset: FullOct2007 &#183; 4.483.032 records total&#10;
                Subset: 4 categories &#183; 613.245 questions&#10;
                Sample: <xsl:value-of select="count(//vespaadd)"/> questions displayed
              </div>
            </div>

            <div class="stats-grid">
              <div class="stat-card total">
                <span class="stat-number"><xsl:value-of select="count(//vespaadd)"/></span>
                <span class="stat-label">Total questions</span>
              </div>
              <div class="stat-card sci">
                <span class="stat-number">
                  <xsl:value-of select="count(//vespaadd[
                    contains(document/maincat,'Science') and not(contains(document/maincat,'Social')) or
                    contains(document/maincat,'Ciencia') or
                    contains(document/maincat,'Wissenschaft') or
                    contains(document/maincat,'Sciences et math')
                  ])"/>
                </span>
                <span class="stat-label">Science &#38; Math</span>
              </div>
              <div class="stat-card edu">
                <span class="stat-number">
                  <xsl:value-of select="count(//vespaadd[
                    contains(document/maincat,'Education') or
                    contains(document/maincat,'ducaci') or
                    contains(document/maincat,'Enseignement') or
                    contains(document/maincat,'Scuola') or
                    contains(document/maincat,'Schule') or
                    contains(document/maincat,'ducação')
                  ])"/>
                </span>
                <span class="stat-label">Education &#38; Ref</span>
              </div>
              <div class="stat-card soc">
                <span class="stat-number">
                  <xsl:value-of select="count(//vespaadd[
                    contains(document/maincat,'Social Science') or
                    contains(document/maincat,'Ciencias Sociales') or
                    contains(document/maincat,'Ciencias sociales') or
                    contains(document/maincat,'Sciences sociales') or
                    contains(document/maincat,'Sozialwissenschaft') or
                    contains(document/maincat,'Scienze sociali') or
                    contains(document/maincat,'Ciências Sociais')
                  ])"/>
                </span>
                <span class="stat-label">Social Science</span>
              </div>
              <div class="stat-card art">
                <span class="stat-number">
                  <xsl:value-of select="count(//vespaadd[
                    contains(document/maincat,'Arts') or
                    contains(document/maincat,'Arte') or
                    contains(document/maincat,'Kunst') or
                    contains(document/maincat,'Humanities')
                  ])"/>
                </span>
                <span class="stat-label">Arts &#38; Humanities</span>
              </div>
              <div class="stat-card total">
                <span class="stat-number"><xsl:value-of select="count(//vespaadd[document/vot_date])"/></span>
                <span class="stat-label">Community voted</span>
              </div>
              <div class="stat-card total">
                <span class="stat-number"><xsl:value-of select="count(//vespaadd[not(document/content) or normalize-space(document/content)=''])"/></span>
                <span class="stat-label">No content field</span>
              </div>
            </div>

            <div class="filter-row">
              <span class="filter-label-txt">Filter by category:</span>
              <label for="fsci" class="filter-btn sci">&#9642; Science &#38; Math</label>
              <label for="fedu" class="filter-btn edu">&#9642; Education &#38; Ref</label>
              <label for="fsoc" class="filter-btn soc">&#9642; Social Science</label>
              <label for="fart" class="filter-btn art">&#9642; Arts &#38; Humanities</label>
            </div>
          </div>
        </header>

        <main>
          <xsl:apply-templates select="//vespaadd"/>
        </main>

        <footer>
          Generated with XSLT 1.0 &#183;
          Yahoo! Answers Dataset FullOct2007 &#183;
          Bases de Datos Avanzadas &#183; UCLM 2025-2026 &#183;
          Alberto Lillo &#38; Manuel Caballero
        </footer>

      </body>
    </html>
  </xsl:template>

  <!-- ============================================================
       TEMPLATE VESPAADD
       IMPORTANTE: Social Science debe comprobarse ANTES que
       Science & Mathematics porque "Social Science" contiene
       la palabra "Science".
  ============================================================ -->
  <xsl:template match="vespaadd">
    <xsl:variable name="mc" select="document/maincat"/>

    <xsl:variable name="cat-class">
      <xsl:choose>
        <!-- Social Science PRIMERO ? contiene "Science" -->
        <xsl:when test="contains($mc,'Social Science') or
                        contains($mc,'Ciencias Sociales') or
                        contains($mc,'Ciencias sociales') or
                        contains($mc,'Sciences sociales') or
                        contains($mc,'Sozialwissenschaft') or
                        contains($mc,'Scienze sociali') or
                        contains($mc,'Ciências Sociais')">soc</xsl:when>
        <!-- Science & Mathematics -->
        <xsl:when test="contains($mc,'Science') or
                        contains($mc,'Ciencia') or
                        contains($mc,'Wissenschaft') or
                        contains($mc,'Sciences et math')">sci</xsl:when>
        <!-- Education -->
        <xsl:when test="contains($mc,'Education') or
                        contains($mc,'ducaci') or
                        contains($mc,'Enseignement') or
                        contains($mc,'Scuola') or
                        contains($mc,'Schule') or
                        contains($mc,'ducação')">edu</xsl:when>
        <!-- Arts & Humanities -->
        <xsl:otherwise>art</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="cat-icon">
      <xsl:choose>
        <xsl:when test="$cat-class='sci'">&#9881;</xsl:when>
        <xsl:when test="$cat-class='edu'">&#128218;</xsl:when>
        <xsl:when test="$cat-class='soc'">&#128101;</xsl:when>
        <xsl:otherwise>&#127912;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <article>
      <xsl:attribute name="class">card card-<xsl:value-of select="$cat-class"/></xsl:attribute>

      <div class="card-stripe"></div>

      <div class="card-body">

        <!-- Cabecera: badge + idioma -->
        <div class="card-top">
          <span>
            <xsl:attribute name="class">badge badge-<xsl:value-of select="$cat-class"/></xsl:attribute>
            <xsl:value-of select="$cat-icon"/>&#160;<xsl:value-of select="$mc"/>
          </span>
          <span class="lang-badge">
            <xsl:call-template name="flag">
              <xsl:with-param name="region" select="document/qintl"/>
            </xsl:call-template>
            &#160;<xsl:value-of select="document/qlang"/>
            <xsl:if test="document/qintl and document/qintl != ''">
              <xsl:text>-</xsl:text><xsl:value-of select="document/qintl"/>
            </xsl:if>
          </span>
        </div>

        <!-- Subcategor?a -->
        <xsl:if test="document/subcat and normalize-space(document/subcat) != ''">
          <div class="subcat">&#8627; <xsl:value-of select="document/subcat"/></div>
        </xsl:if>

        <!-- Pregunta -->
        <h2 class="question"><xsl:value-of select="document/subject"/></h2>

        <!-- Contenido opcional -->
        <xsl:if test="document/content and normalize-space(document/content) != ''">
          <p class="content-text">
            <xsl:value-of select="document/content"/>
          </p>
        </xsl:if>

        <!-- Mejor respuesta -->
        <div class="best-answer">
          <div class="best-answer-label">
            <xsl:choose>
              <xsl:when test="document/vot_date">&#127942; Best Answer &#183; voted by community</xsl:when>
              <xsl:otherwise>&#9997; Best Answer &#183; chosen by author</xsl:otherwise>
            </xsl:choose>
          </div>
          <xsl:choose>
            <xsl:when test="document/bestanswer and normalize-space(document/bestanswer) != ''">
              <div class="best-answer-text">
                <xsl:value-of select="document/bestanswer"/>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="best-answer-text" style="color:#a0aec0;font-style:italic">No best answer recorded.</div>
            </xsl:otherwise>
          </xsl:choose>
        </div>

        <!-- Respuestas alternativas -->
        <xsl:if test="document/nbestanswers/answer_item">
          <details class="alt">
            <summary>
              &#128172; <xsl:value-of select="count(document/nbestanswers/answer_item)"/> alternative answer(s) &#8212; click to expand
            </summary>
            <xsl:for-each select="document/nbestanswers/answer_item">
              <div class="alt-item">
                <span class="alt-n">#<xsl:value-of select="position()"/></span>
                <xsl:value-of select="."/>
              </div>
            </xsl:for-each>
          </details>
        </xsl:if>

      </div><!-- /card-body -->

      <!-- Pie de tarjeta -->
      <div class="card-footer">
        <div class="dates">
          <span class="date-item">
            &#128197; Posted:
            <xsl:call-template name="unix-to-date">
              <xsl:with-param name="ts" select="document/date"/>
            </xsl:call-template>
          </span>
          <xsl:if test="document/res_date and normalize-space(document/res_date) != ''">
            <span class="date-item">
              &#10003; Resolved:
              <xsl:call-template name="unix-to-date">
                <xsl:with-param name="ts" select="document/res_date"/>
              </xsl:call-template>
            </span>
          </xsl:if>
        </div>
        <div class="meta-right">
          <xsl:choose>
            <xsl:when test="document/vot_date">
              <span class="voted-badge">&#11088; Community pick</span>
            </xsl:when>
            <xsl:otherwise>
              <span class="author-badge">&#9997; Author pick</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="document/id and normalize-space(document/id) != ''">
            <span class="author-id">&#128100; <xsl:value-of select="document/id"/></span>
          </xsl:if>
          <span class="uri-badge">#<xsl:value-of select="document/uri"/></span>
        </div>
      </div>

    </article>
  </xsl:template>

  <!-- ============================================================
       TEMPLATE unix-to-date
  ============================================================ -->
  <xsl:template name="unix-to-date">
    <xsl:param name="ts"/>
    <xsl:if test="$ts and normalize-space($ts) != ''">
      <xsl:variable name="d"    select="floor($ts div 86400)"/>
      <xsl:variable name="z"    select="$d + 719468"/>
      <xsl:variable name="era"  select="floor($z div 146097)"/>
      <xsl:variable name="doe"  select="$z - $era * 146097"/>
      <xsl:variable name="yoe"  select="floor(($doe - floor($doe div 1460) + floor($doe div 36524) - floor($doe div 146096)) div 365)"/>
      <xsl:variable name="y0"   select="$yoe + $era * 400"/>
      <xsl:variable name="doy"  select="$doe - (365 * $yoe + floor($yoe div 4) - floor($yoe div 100))"/>
      <xsl:variable name="mp"   select="floor((5 * $doy + 2) div 153)"/>
      <xsl:variable name="day"  select="$doy - floor((153 * $mp + 2) div 5) + 1"/>
      <xsl:variable name="mnum">
        <xsl:choose>
          <xsl:when test="$mp + 3 &lt;= 12"><xsl:value-of select="$mp + 3"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$mp - 9"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="year">
        <xsl:choose>
          <xsl:when test="$mnum &lt;= 2"><xsl:value-of select="$y0 + 1"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$y0"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="mname">
        <xsl:choose>
          <xsl:when test="$mnum = 1">Jan</xsl:when>
          <xsl:when test="$mnum = 2">Feb</xsl:when>
          <xsl:when test="$mnum = 3">Mar</xsl:when>
          <xsl:when test="$mnum = 4">Apr</xsl:when>
          <xsl:when test="$mnum = 5">May</xsl:when>
          <xsl:when test="$mnum = 6">Jun</xsl:when>
          <xsl:when test="$mnum = 7">Jul</xsl:when>
          <xsl:when test="$mnum = 8">Aug</xsl:when>
          <xsl:when test="$mnum = 9">Sep</xsl:when>
          <xsl:when test="$mnum = 10">Oct</xsl:when>
          <xsl:when test="$mnum = 11">Nov</xsl:when>
          <xsl:when test="$mnum = 12">Dec</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat($day, ' ', $mname, ' ', $year)"/>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================
       TEMPLATE flag
  ============================================================ -->
  <xsl:template name="flag">
    <xsl:param name="region"/>
    <xsl:choose>
      <xsl:when test="$region = 'us'">&#127482;&#127480;</xsl:when>
      <xsl:when test="$region = 'uk'">&#127468;&#127463;</xsl:when>
      <xsl:when test="$region = 'es' or $region = 'e1'">&#127466;&#127480;</xsl:when>
      <xsl:when test="$region = 'fr'">&#127467;&#127479;</xsl:when>
      <xsl:when test="$region = 'de'">&#127465;&#127466;</xsl:when>
      <xsl:when test="$region = 'it'">&#127470;&#127481;</xsl:when>
      <xsl:when test="$region = 'br'">&#127463;&#127479;</xsl:when>
      <xsl:when test="$region = 'pt'">&#127477;&#127481;</xsl:when>
      <xsl:when test="$region = 'mx'">&#127474;&#127485;</xsl:when>
      <xsl:when test="$region = 'ar'">&#127462;&#127479;</xsl:when>
      <xsl:when test="$region = 'au'">&#127462;&#127482;</xsl:when>
      <xsl:when test="$region = 'ca'">&#127464;&#127462;</xsl:when>
      <xsl:when test="$region = 'in'">&#127470;&#127475;</xsl:when>
      <xsl:when test="$region = 'sg'">&#127480;&#127468;</xsl:when>
      <xsl:when test="$region = 'ph'">&#127477;&#127469;</xsl:when>
      <xsl:when test="$region = 'my'">&#127474;&#127486;</xsl:when>
      <xsl:otherwise>&#127760;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
