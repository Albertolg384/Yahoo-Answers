(:
  ================================================================
  BLOQUE 1 - ESTADISTICAS GENERALES (VERSION FINAL CORREGIDA)
  Proyecto: Trabajo XML - Bases de Datos Avanzadas
  Autores:  Alberto Lillo Garcia y Manuel Caballero Bonilla
  ================================================================
:)

(: Variables de categoria reutilizadas en Q1 y Q4 :)
let $sci := (
  db:text("yahoo_answers","Science &amp; Mathematics")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Ciencia y Matemáticas")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Ciências e Matemática")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Sciences et mathématiques")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Wissenschaft &amp; Mathematik")/parent::maincat/parent::document/parent::vespaadd
)
let $edu := (
  db:text("yahoo_answers","Education &amp; Reference")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Educación")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Educación y Formación")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Educação e Referência")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Enseignement et référence")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Scuola ed educazione")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Schule &amp; Bildung")/parent::maincat/parent::document/parent::vespaadd
)
let $soc := (
  db:text("yahoo_answers","Social Science")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Ciencias Sociales")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Ciencias sociales")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Sciences sociales")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Sozialwissenschaft")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Scienze sociali")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Ciências Sociais")/parent::maincat/parent::document/parent::vespaadd
)
let $art := (
  db:text("yahoo_answers","Arts &amp; Humanities")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Arte y Humanidades")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Artes e Humanidades")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Arts et sciences humaines")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Kunst &amp; Geisteswissenschaft")/parent::maincat/parent::document/parent::vespaadd,
  db:text("yahoo_answers","Arte e cultura")/parent::maincat/parent::document/parent::vespaadd
)

let $total := count(db:get("yahoo_answers")/yahooAnswers/vespaadd)

(: Q1: PERFIL ESTADISTICO COMPLETO POR CATEGORIA :)
let $q1 :=
  <q1_perfil_por_categoria>
    <categoria nombre="Science and Mathematics">
      <total_preguntas>{count($sci)}</total_preguntas>
      <porcentaje_del_subset>{format-number(count($sci) div $total * 100,'0.00')}%</porcentaje_del_subset>
      <subcategorias_unicas>{count(distinct-values($sci/document/subcat))}</subcategorias_unicas>
      <sin_campo_content>{count($sci[not(document/content) or normalize-space(document/content)=''])}</sin_campo_content>
      <con_vot_date>{count($sci[document/vot_date])}</con_vot_date>
      <pct_vot_date>{format-number(count($sci[document/vot_date]) div count($sci) * 100,'0.00')}%</pct_vot_date>
      <media_respuestas_alt>{format-number(avg($sci/document/nbestanswers/count(answer_item)),'0.00')}</media_respuestas_alt>
      <max_respuestas_alt>{max($sci/document/nbestanswers/count(answer_item))}</max_respuestas_alt>
    </categoria>
    <categoria nombre="Education and Reference">
      <total_preguntas>{count($edu)}</total_preguntas>
      <porcentaje_del_subset>{format-number(count($edu) div $total * 100,'0.00')}%</porcentaje_del_subset>
      <subcategorias_unicas>{count(distinct-values($edu/document/subcat))}</subcategorias_unicas>
      <sin_campo_content>{count($edu[not(document/content) or normalize-space(document/content)=''])}</sin_campo_content>
      <con_vot_date>{count($edu[document/vot_date])}</con_vot_date>
      <pct_vot_date>{format-number(count($edu[document/vot_date]) div count($edu) * 100,'0.00')}%</pct_vot_date>
      <media_respuestas_alt>{format-number(avg($edu/document/nbestanswers/count(answer_item)),'0.00')}</media_respuestas_alt>
      <max_respuestas_alt>{max($edu/document/nbestanswers/count(answer_item))}</max_respuestas_alt>
    </categoria>
    <categoria nombre="Social Science">
      <total_preguntas>{count($soc)}</total_preguntas>
      <porcentaje_del_subset>{format-number(count($soc) div $total * 100,'0.00')}%</porcentaje_del_subset>
      <subcategorias_unicas>{count(distinct-values($soc/document/subcat))}</subcategorias_unicas>
      <sin_campo_content>{count($soc[not(document/content) or normalize-space(document/content)=''])}</sin_campo_content>
      <con_vot_date>{count($soc[document/vot_date])}</con_vot_date>
      <pct_vot_date>{format-number(count($soc[document/vot_date]) div count($soc) * 100,'0.00')}%</pct_vot_date>
      <media_respuestas_alt>{format-number(avg($soc/document/nbestanswers/count(answer_item)),'0.00')}</media_respuestas_alt>
      <max_respuestas_alt>{max($soc/document/nbestanswers/count(answer_item))}</max_respuestas_alt>
    </categoria>
    <categoria nombre="Arts and Humanities">
      <total_preguntas>{count($art)}</total_preguntas>
      <porcentaje_del_subset>{format-number(count($art) div $total * 100,'0.00')}%</porcentaje_del_subset>
      <subcategorias_unicas>{count(distinct-values($art/document/subcat))}</subcategorias_unicas>
      <sin_campo_content>{count($art[not(document/content) or normalize-space(document/content)=''])}</sin_campo_content>
      <con_vot_date>{count($art[document/vot_date])}</con_vot_date>
      <pct_vot_date>{format-number(count($art[document/vot_date]) div count($art) * 100,'0.00')}%</pct_vot_date>
      <media_respuestas_alt>{format-number(avg($art/document/nbestanswers/count(answer_item)),'0.00')}</media_respuestas_alt>
      <max_respuestas_alt>{max($art/document/nbestanswers/count(answer_item))}</max_respuestas_alt>
    </categoria>
  </q1_perfil_por_categoria>

(: Q2: TOP 15 SUBCATEGORIAS :)
let $q2 :=
  <q2_top15_subcategorias>
  {
    subsequence(
      for $sc in distinct-values(
        db:get("yahoo_answers")/yahooAnswers/vespaadd/document/subcat[. != '']
      )
      let $c := count(
        db:text("yahoo_answers", $sc)/parent::subcat/parent::document/parent::vespaadd
      )
      order by $c descending
      return <subcategoria nombre="{$sc}" preguntas="{$c}"/>
    , 1, 15)
  }
  </q2_top15_subcategorias>

(: Q3: DISTRIBUCION DE IDIOMAS Y REGIONES :)
let $q3 :=
  <q3_distribucion_idiomas_regiones>
    <por_idioma>
    {
      for $lang in distinct-values(
        db:get("yahoo_answers")/yahooAnswers/vespaadd/document/qlang[. != '']
      )
      let $c := count(
        db:text("yahoo_answers", $lang)/parent::qlang/parent::document/parent::vespaadd
      )
      order by $c descending
      return <idioma codigo="{$lang}" preguntas="{$c}"
                     porcentaje="{format-number($c div $total * 100,'0.00')}%"/>
    }
    </por_idioma>
    <por_region>
    {
      for $reg in distinct-values(
        db:get("yahoo_answers")/yahooAnswers/vespaadd/document/qintl[. != '']
      )
      let $c := count(
        db:text("yahoo_answers", $reg)/parent::qintl/parent::document/parent::vespaadd
      )
      order by $c descending
      return <region codigo="{$reg}" preguntas="{$c}"
                     porcentaje="{format-number($c div $total * 100,'0.00')}%"/>
    }
    </por_region>
    <top10_combinaciones_idioma_region>
    {
      subsequence(
        for $combo in distinct-values(
          db:get("yahoo_answers")/yahooAnswers/vespaadd/document/language[. != '']
        )
        let $c := count(
          db:text("yahoo_answers", $combo)/parent::language/parent::document/parent::vespaadd
        )
        order by $c descending
        return <combinacion codigo="{$combo}" preguntas="{$c}"/>
      , 1, 10)
    }
    </top10_combinaciones_idioma_region>
  </q3_distribucion_idiomas_regiones>

(: Q4: AUTOR VS COMUNIDAD POR CATEGORIA :)
let $q4 :=
  <q4_autor_vs_comunidad>
    <categoria nombre="Science and Mathematics">
      <total>{count($sci)}</total>
      <elegidas_por_autor>{count($sci[not(document/vot_date)])}</elegidas_por_autor>
      <pct_autor>{format-number(count($sci[not(document/vot_date)]) div count($sci) * 100,'0.00')}%</pct_autor>
      <elegidas_por_comunidad>{count($sci[document/vot_date])}</elegidas_por_comunidad>
      <pct_comunidad>{format-number(count($sci[document/vot_date]) div count($sci) * 100,'0.00')}%</pct_comunidad>
    </categoria>
    <categoria nombre="Education and Reference">
      <total>{count($edu)}</total>
      <elegidas_por_autor>{count($edu[not(document/vot_date)])}</elegidas_por_autor>
      <pct_autor>{format-number(count($edu[not(document/vot_date)]) div count($edu) * 100,'0.00')}%</pct_autor>
      <elegidas_por_comunidad>{count($edu[document/vot_date])}</elegidas_por_comunidad>
      <pct_comunidad>{format-number(count($edu[document/vot_date]) div count($edu) * 100,'0.00')}%</pct_comunidad>
    </categoria>
    <categoria nombre="Social Science">
      <total>{count($soc)}</total>
      <elegidas_por_autor>{count($soc[not(document/vot_date)])}</elegidas_por_autor>
      <pct_autor>{format-number(count($soc[not(document/vot_date)]) div count($soc) * 100,'0.00')}%</pct_autor>
      <elegidas_por_comunidad>{count($soc[document/vot_date])}</elegidas_por_comunidad>
      <pct_comunidad>{format-number(count($soc[document/vot_date]) div count($soc) * 100,'0.00')}%</pct_comunidad>
    </categoria>
    <categoria nombre="Arts and Humanities">
      <total>{count($art)}</total>
      <elegidas_por_autor>{count($art[not(document/vot_date)])}</elegidas_por_autor>
      <pct_autor>{format-number(count($art[not(document/vot_date)]) div count($art) * 100,'0.00')}%</pct_autor>
      <elegidas_por_comunidad>{count($art[document/vot_date])}</elegidas_por_comunidad>
      <pct_comunidad>{format-number(count($art[document/vot_date]) div count($art) * 100,'0.00')}%</pct_comunidad>
    </categoria>
  </q4_autor_vs_comunidad>

return
<bloque1_estadisticas_generales>
  {$q1}
  {$q2}
  {$q3}
  {$q4}
</bloque1_estadisticas_generales>
