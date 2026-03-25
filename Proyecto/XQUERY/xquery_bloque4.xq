(:
  ================================================================
  BLOQUE 4 - CALIDAD DE DATOS
  Proyecto: Trabajo XML - Bases de Datos Avanzadas
  Autores:  Alberto Lillo Garcia y Manuel Caballero Bonilla

  Q14 - Anomalias de campos mandatory desagregadas por categoria
  Q15 - Respuestas "fantasma": best_id que no aparece en ningun
        answer_item del mismo registro
  Q16 - Inconsistencias temporales: res_date anterior a date
  Q17 - Timestamps identicos en date + res_date (datos sinteticos)
  Q18 - Distribucion del codigo "e1" en qintl y su impacto

  DIFERENCIA con Paso 3 de memoria: aqui la desagregacion es por categoria
  y el enfoque es el IMPACTO sobre la calidad, no solo los conteos.

  ================================================================
:)

let $all := db:get("yahoo_answers")/yahooAnswers/vespaadd

let $sci_mc := ("Science &amp; Mathematics","Ciencia y Matemáticas","Ciências e Matemática",
                "Sciences et mathématiques","Wissenschaft &amp; Mathematik")
let $edu_mc := ("Education &amp; Reference","Educación","Educación y Formación",
                "Educação e Referência","Enseignement et référence",
                "Scuola ed educazione","Schule &amp; Bildung")
let $soc_mc := ("Social Science","Ciencias Sociales","Ciencias sociales",
                "Sciences sociales","Sozialwissenschaft","Scienze sociali","Ciências Sociais")
let $art_mc := ("Arts &amp; Humanities","Arte y Humanidades","Artes e Humanidades",
                "Arts et sciences humaines","Kunst &amp; Geisteswissenschaft","Arte e cultura")

(: Q14: ANOMALIAS DE CAMPOS MANDATORY POR CATEGORIA :)
(: Los campos uri, subject, date son obligatorios segun la doc
   bestanswer, best_id, id, nbestanswers, lastanswerts son
   obligatorios en la doc pero presentan anomalias en los datos :)
let $q14 :=
  <q14_anomalias_por_categoria>
  {
    for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
    let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
               else if ($cat_name = "Education and Reference") then $edu_mc
               else if ($cat_name = "Social Science") then $soc_mc
               else $art_mc
    let $regs := $all[document/maincat = $mc]
    let $n := count($regs)
    return
    <categoria nombre="{$cat_name}" total="{$n}">
      <campo_id ausente="{count($regs[not(document/id) or normalize-space(document/id)=''])}"
                pct="{format-number(count($regs[not(document/id) or normalize-space(document/id)='']) div $n * 100,'0.000')}%"/>
      <campo_bestanswer ausente="{count($regs[not(document/bestanswer) or normalize-space(document/bestanswer)=''])}"
                        pct="{format-number(count($regs[not(document/bestanswer) or normalize-space(document/bestanswer)='']) div $n * 100,'0.00')}%"/>
      <campo_best_id ausente="{count($regs[not(document/best_id) or normalize-space(document/best_id)=''])}"
                     pct="{format-number(count($regs[not(document/best_id) or normalize-space(document/best_id)='']) div $n * 100,'0.00')}%"/>
      <campo_nbestanswers ausente="{count($regs[not(document/nbestanswers)])}"
                          pct="{format-number(count($regs[not(document/nbestanswers)]) div $n * 100,'0.000')}%"/>
    </categoria>
  }
  </q14_anomalias_por_categoria>

(: Q15: RESPUESTAS "FANTASMA" :)
(: Registros donde best_id no coincide con ningun answer_item del mismo registro.
   El best_id deberia corresponder al autor de una de las respuestas alternativas :)
let $q15 :=
  <q15_respuestas_fantasma>
    <descripcion>Registros donde best_id no aparece en ningun answer_item como autor</descripcion>
  {
    let $total_con_best_id := count($all[document/best_id and normalize-space(document/best_id) != ''])
    (: En este dataset los answer_items no tienen campo autor identificable separado,
       pero si podemos detectar registros con best_id pero sin ninguna respuesta alternativa :)
    let $sin_respuestas := $all[
      document/best_id[. != ''] and
      (not(document/nbestanswers/answer_item) or count(document/nbestanswers/answer_item) = 0)
    ]
    return
    <estadisticas>
      <total_con_best_id>{$total_con_best_id}</total_con_best_id>
      <con_best_id_sin_alternativas>{count($sin_respuestas)}</con_best_id_sin_alternativas>
      <pct_sin_alternativas>{format-number(count($sin_respuestas) div $total_con_best_id * 100,'0.00')}%</pct_sin_alternativas>
      <por_categoria>
      {
        for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
        let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
                   else if ($cat_name = "Education and Reference") then $edu_mc
                   else if ($cat_name = "Social Science") then $soc_mc
                   else $art_mc
        let $cat_regs := $sin_respuestas[document/maincat = $mc]
        return <categoria nombre="{$cat_name}" count="{count($cat_regs)}"/>
      }
      </por_categoria>
    </estadisticas>
  }
  </q15_respuestas_fantasma>

(: Q16: INCONSISTENCIAS TEMPORALES :)
(: res_date anterior a date: la resolucion no puede ser anterior a la pregunta :)
let $q16 :=
  <q16_inconsistencias_temporales>
    <descripcion>Registros donde res_date es anterior a date</descripcion>
  {
    let $inconsistentes := $all[
      document/res_date[. != ''] and
      document/date[. != ''] and
      xs:integer(document/res_date) lt xs:integer(document/date)
    ]
    let $total_con_resdate := count($all[document/res_date and normalize-space(document/res_date) != ''])
    return
    <estadisticas>
      <total_con_res_date>{$total_con_resdate}</total_con_res_date>
      <res_date_anterior_a_date>{count($inconsistentes)}</res_date_anterior_a_date>
      <pct_inconsistentes>{format-number(count($inconsistentes) div $total_con_resdate * 100,'0.00')}%</pct_inconsistentes>
      <por_categoria>
      {
        for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
        let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
                   else if ($cat_name = "Education and Reference") then $edu_mc
                   else if ($cat_name = "Social Science") then $soc_mc
                   else $art_mc
        let $n := count($inconsistentes[document/maincat = $mc])
        return <categoria nombre="{$cat_name}" count="{$n}"/>
      }
      </por_categoria>
    </estadisticas>
  }
  </q16_inconsistencias_temporales>

(: Q17: TIMESTAMPS IDENTICOS date = res_date :)
(: Registros donde la pregunta y su resolucion tienen el mismo timestamp exacto
   Posibles datos de prueba o ingresados manualmente :)
let $q17 :=
  <q17_timestamps_identicos_date_resdate>
    <descripcion>Registros donde date = res_date exactamente (resolucion instantanea)</descripcion>
  {
    let $identicos := $all[
      document/res_date[. != ''] and
      document/date[. != ''] and
      document/date = document/res_date
    ]
    let $total_con_ambos := count($all[
      document/res_date[. != ''] and document/date[. != '']
    ])
    return
    <estadisticas>
      <total_con_date_y_resdate>{$total_con_ambos}</total_con_date_y_resdate>
      <con_timestamps_identicos>{count($identicos)}</con_timestamps_identicos>
      <pct_identicos>{format-number(count($identicos) div $total_con_ambos * 100,'0.00')}%</pct_identicos>
      <por_categoria>
      {
        for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
        let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
                   else if ($cat_name = "Education and Reference") then $edu_mc
                   else if ($cat_name = "Social Science") then $soc_mc
                   else $art_mc
        let $n := count($identicos[document/maincat = $mc])
        return <categoria nombre="{$cat_name}" count="{$n}"/>
      }
      </por_categoria>
    </estadisticas>
  }
  </q17_timestamps_identicos_date_resdate>

(: Q18: DISTRIBUCION DEL CODIGO "e1" EN qintl :)
let $q18 :=
  <q18_codigo_e1_impacto>
    <descripcion>Registros con qintl="e1" y su distribucion por categoria y combinacion language</descripcion>
  {
    let $e1_regs := db:text("yahoo_answers","e1")/parent::qintl/parent::document/parent::vespaadd
    let $total   := count(db:get("yahoo_answers")/yahooAnswers/vespaadd)
    return
    <estadisticas>
      <total_registros_e1>{count($e1_regs)}</total_registros_e1>
      <pct_del_total>{format-number(count($e1_regs) div $total * 100,'0.00')}%</pct_del_total>
      <combinaciones_language>
      {
        for $lang in distinct-values($e1_regs/document/language[. != ''])
        let $n := count($e1_regs[document/language = $lang])
        order by $n descending
        return <language codigo="{$lang}" preguntas="{$n}"/>
      }
      </combinaciones_language>
      <por_categoria>
      {
        for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
        let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
                   else if ($cat_name = "Education and Reference") then $edu_mc
                   else if ($cat_name = "Social Science") then $soc_mc
                   else $art_mc
        let $n := count($e1_regs[document/maincat = $mc])
        return <categoria nombre="{$cat_name}" count="{$n}"/>
      }
      </por_categoria>
    </estadisticas>
  }
  </q18_codigo_e1_impacto>

return
<bloque4_calidad_datos>
  {$q14}
  {$q15}
  {$q16}
  {$q17}
  {$q18}
</bloque4_calidad_datos>
