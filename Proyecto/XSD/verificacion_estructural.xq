(:
  ================================================================
  VERIFICACIÓN ESTRUCTURAL - Yahoo! Answers
  Proyecto: Trabajo XML - Bases de Datos Avanzadas
  Autores:  Alberto Lillo García y Manuel Caballero Bonilla

  INSTRUCCIONES:
  1. Abrir BaseX GUI
  2. Seleccionar la base de datos yahoo_answers
  3. File  Open  seleccionar este archivo .xq
  4. Ejecutar con el botón
  Todo el script es UNA SOLA expresión XQuery válida.
  ================================================================
:)

let $total := count(//vespaadd)

(: ── BLOQUE 1: Verificación general ── :)
let $b1_total        := count(//vespaadd)
let $b1_type_vals    := string-join(distinct-values(//document/@type), ", ")
let $b1_maincat_vals := string-join(sort(distinct-values(//document/maincat)), " | ")
let $b1_sci   := count(//vespaadd[document/maincat = "Science &amp; Mathematics"])
let $b1_edu   := count(//vespaadd[document/maincat = "Education &amp; Reference"])
let $b1_soc   := count(//vespaadd[document/maincat = "Social Science"])
let $b1_arts  := count(//vespaadd[document/maincat = "Arts &amp; Humanities"])

(: ── BLOQUE 2: Campos obligatorios (esperado: 0 en todos) ── :)
let $b2_uri          := count(//vespaadd[not(document/uri)])
let $b2_subject      := count(//vespaadd[not(document/subject)])
let $b2_bestanswer   := count(//vespaadd[not(document/bestanswer)])
let $b2_nbestanswers := count(//vespaadd[not(document/nbestanswers)])
let $b2_id           := count(//vespaadd[not(document/id)])
let $b2_best_id      := count(//vespaadd[not(document/best_id)])
let $b2_date         := count(//vespaadd[not(document/date)])
let $b2_lastanswerts := count(//vespaadd[not(document/lastanswerts)])

(: ── BLOQUE 3: Campos opcionales (cuántos NO tienen el campo) ── :)
let $b3_content      := count(//vespaadd[not(document/content)])
let $b3_maincat      := count(//vespaadd[not(document/maincat)])
let $b3_cat          := count(//vespaadd[not(document/cat)])
let $b3_subcat       := count(//vespaadd[not(document/subcat)])
let $b3_qlang        := count(//vespaadd[not(document/qlang)])
let $b3_qintl        := count(//vespaadd[not(document/qintl)])
let $b3_language     := count(//vespaadd[not(document/language)])
let $b3_res_date     := count(//vespaadd[not(document/res_date)])
let $b3_vot_date     := count(//vespaadd[not(document/vot_date)])

(: ── BLOQUE 4: Verificación de tipos y formatos ── :)
let $b4_uri_nonum    := count(//vespaadd[not(matches(document/uri, "^\d+$"))])
let $b4_id_badpat    := count(//vespaadd[document/id and not(matches(document/id, "^u[0-9]+$"))])
let $b4_bestid_bad   := count(//vespaadd[not(matches(document/best_id, "^u[0-9]+$"))])
let $b4_date_nonum   := count(//vespaadd[not(matches(document/date, "^\d+$"))])
let $b4_last_nonum   := count(//vespaadd[not(matches(document/lastanswerts, "^\d+$"))])
let $b4_res_nonum    := count(//vespaadd[document/res_date and not(matches(document/res_date, "^\d+$"))])
let $b4_vot_nonum    := count(//vespaadd[document/vot_date and not(matches(document/vot_date, "^\d+$"))])
let $b4_qlang_vals   := string-join(sort(distinct-values(//document/qlang)), ", ")
let $b4_qintl_vals   := string-join(sort(distinct-values(//document/qintl)), ", ")
let $b4_lang_vals    := string-join(sort(distinct-values(//document/language)), ", ")
let $b4_qlang_bad    := count(//vespaadd[document/qlang and not(matches(document/qlang, "^[a-z]{2}$"))])
let $b4_qintl_bad    := count(//vespaadd[document/qintl and not(matches(document/qintl, "^[a-z]{2}$"))])
let $b4_lang_bad     := count(//vespaadd[document/language and not(matches(document/language, "^[a-z]{2}-[a-z]{2}$"))])

(: ── BLOQUE 5: Análisis de nbestanswers ── :)
let $b5_empty        := count(//vespaadd[not(document/nbestanswers/answer_item)])
let $b5_max          := max(//nbestanswers/count(answer_item))
let $b5_min          := min(//nbestanswers[answer_item]/count(answer_item))
let $b5_avg          := avg(//nbestanswers/count(answer_item))

(: ── BLOQUE 6: Campos presentes pero vacíos ── :)
let $b6_subject_vac  := count(//vespaadd[document/subject[normalize-space(.) = ""]])
let $b6_content_vac  := count(//vespaadd[document/content[normalize-space(.) = ""]])
let $b6_best_vac     := count(//vespaadd[document/bestanswer[normalize-space(.) = ""]])
let $b6_item_vac     := count(//nbestanswers/answer_item[normalize-space(.) = ""])

return
<verificacion_estructural total_registros="{$total}">

  <bloque1_general>
    <total_vespaadd>{$b1_total}</total_vespaadd>
    <valores_atributo_type>{$b1_type_vals}</valores_atributo_type>
    <valores_maincat>{$b1_maincat_vals}</valores_maincat>
    <por_categoria>
      <science_mathematics>{$b1_sci}</science_mathematics>
      <education_reference>{$b1_edu}</education_reference>
      <social_science>{$b1_soc}</social_science>
      <arts_humanities>{$b1_arts}</arts_humanities>
    </por_categoria>
  </bloque1_general>

  <bloque2_obligatorios nota="esperado 0 en todos">
    <sin_uri>{$b2_uri}</sin_uri>
    <sin_subject>{$b2_subject}</sin_subject>
    <sin_bestanswer>{$b2_bestanswer}</sin_bestanswer>
    <sin_nbestanswers>{$b2_nbestanswers}</sin_nbestanswers>
    <sin_id nota="ANOMALIA si distinto de 0: doc oficial dice mandatory">{$b2_id}</sin_id>
    <sin_best_id>{$b2_best_id}</sin_best_id>
    <sin_date>{$b2_date}</sin_date>
    <sin_lastanswerts>{$b2_lastanswerts}</sin_lastanswerts>
  </bloque2_obligatorios>

  <bloque3_opcionales nota="registros que NO tienen el campo">
    <sin_content>{$b3_content}</sin_content>
    <sin_maincat>{$b3_maincat}</sin_maincat>
    <sin_cat>{$b3_cat}</sin_cat>
    <sin_subcat>{$b3_subcat}</sin_subcat>
    <sin_qlang>{$b3_qlang}</sin_qlang>
    <sin_qintl>{$b3_qintl}</sin_qintl>
    <sin_language>{$b3_language}</sin_language>
    <sin_res_date>{$b3_res_date}</sin_res_date>
    <sin_vot_date>{$b3_vot_date}</sin_vot_date>
  </bloque3_opcionales>

  <bloque4_tipos nota="esperado 0 = formato correcto en todos">
    <uri_no_numerico>{$b4_uri_nonum}</uri_no_numerico>
    <id_patron_incorrecto>{$b4_id_badpat}</id_patron_incorrecto>
    <best_id_patron_incorrecto>{$b4_bestid_bad}</best_id_patron_incorrecto>
    <date_no_numerico>{$b4_date_nonum}</date_no_numerico>
    <lastanswerts_no_numerico>{$b4_last_nonum}</lastanswerts_no_numerico>
    <res_date_no_numerico>{$b4_res_nonum}</res_date_no_numerico>
    <vot_date_no_numerico>{$b4_vot_nonum}</vot_date_no_numerico>
    <valores_qlang>{$b4_qlang_vals}</valores_qlang>
    <valores_qintl>{$b4_qintl_vals}</valores_qintl>
    <valores_language>{$b4_lang_vals}</valores_language>
    <qlang_fuera_patron>{$b4_qlang_bad}</qlang_fuera_patron>
    <qintl_fuera_patron>{$b4_qintl_bad}</qintl_fuera_patron>
    <language_fuera_patron>{$b4_lang_bad}</language_fuera_patron>
  </bloque4_tipos>

  <bloque5_nbestanswers>
    <registros_sin_answer_item>{$b5_empty}</registros_sin_answer_item>
    <maximo_answer_items>{$b5_max}</maximo_answer_items>
    <minimo_answer_items_cuando_hay>{$b5_min}</minimo_answer_items_cuando_hay>
    <media_answer_items>{$b5_avg}</media_answer_items>
  </bloque5_nbestanswers>

  <bloque6_campos_vacios nota="campo presente pero sin contenido">
    <subject_vacio>{$b6_subject_vac}</subject_vacio>
    <content_vacio>{$b6_content_vac}</content_vacio>
    <bestanswer_vacio>{$b6_best_vac}</bestanswer_vacio>
    <answer_item_vacio>{$b6_item_vac}</answer_item_vacio>
  </bloque6_campos_vacios>

</verificacion_estructural>
