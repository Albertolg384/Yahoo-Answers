(:
  BLOQUE 5B - Q21 y Q22: Tiempo de resolucion
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

(: Pre-filtramos registros validos para reutilizar en Q21 y Q22 :)
(: Usamos FOR explicito para que BaseX no pueda hacer hoisting :)

let $q21 :=
  <q21_tiempo_medio_resolucion>
    <descripcion>Tiempo medio entre date y res_date en dias, por categoria</descripcion>
  {
    let $total_validos := count(
      for $rec in $all
      let $rd_str := string(($rec/document/res_date[. != ''])[1])
      let $d_str  := string(($rec/document/date[. != ''])[1])
      where $rd_str != '' and $d_str != ''
        and xs:integer($rd_str) >= xs:integer($d_str)
      return $rec
    )
    let $media_global := avg(
      for $rec in $all
      let $rd_str := string(($rec/document/res_date[. != ''])[1])
      let $d_str  := string(($rec/document/date[. != ''])[1])
      where $rd_str != '' and $d_str != ''
        and xs:integer($rd_str) >= xs:integer($d_str)
      return (xs:integer($rd_str) - xs:integer($d_str)) div 86400
    )
    return
    <global registros="{$total_validos}"
            media_dias="{format-number($media_global,'0.00')}"/>
  }
  {
    for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
    let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
               else if ($cat_name = "Education and Reference") then $edu_mc
               else if ($cat_name = "Social Science") then $soc_mc
               else $art_mc
    let $diffs_cat :=
      for $rec in $all[document/maincat = $mc]
      let $rd_str := string(($rec/document/res_date[. != ''])[1])
      let $d_str  := string(($rec/document/date[. != ''])[1])
      where $rd_str != '' and $d_str != ''
        and xs:integer($rd_str) >= xs:integer($d_str)
      return (xs:integer($rd_str) - xs:integer($d_str)) div 86400
    return
    <categoria nombre="{$cat_name}"
               registros="{count($diffs_cat)}"
               media_dias="{format-number(avg($diffs_cat),'0.00')}"/>
  }
  </q21_tiempo_medio_resolucion>

let $q22 :=
  <q22_distribucion_rangos_resolucion>
    <descripcion>Preguntas agrupadas por tiempo de resolucion (date a res_date)</descripcion>
  {
    for $cat_name in ("Global","Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
    let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
               else if ($cat_name = "Education and Reference") then $edu_mc
               else if ($cat_name = "Social Science") then $soc_mc
               else if ($cat_name = "Arts and Humanities") then $art_mc
               else ()
    let $diffs :=
      for $rec in (if ($cat_name = "Global") then $all else $all[document/maincat = $mc])
      let $rd_str := string(($rec/document/res_date[. != ''])[1])
      let $d_str  := string(($rec/document/date[. != ''])[1])
      where $rd_str != '' and $d_str != ''
        and xs:integer($rd_str) >= xs:integer($d_str)
      return xs:integer($rd_str) - xs:integer($d_str)
    let $n  := count($diffs)
    let $r1 := count($diffs[. lt 3600])
    let $r2 := count($diffs[. ge 3600 and . lt 86400])
    let $r3 := count($diffs[. ge 86400 and . lt 604800])
    let $r4 := count($diffs[. ge 604800 and . lt 2592000])
    let $r5 := count($diffs[. ge 2592000])
    return
    <categoria nombre="{$cat_name}" total="{$n}">
      <menos_1h     count="{$r1}" pct="{format-number($r1 div $n * 100,'0.00')}%"/>
      <entre_1h_24h count="{$r2}" pct="{format-number($r2 div $n * 100,'0.00')}%"/>
      <entre_1d_7d  count="{$r3}" pct="{format-number($r3 div $n * 100,'0.00')}%"/>
      <entre_7d_30d count="{$r4}" pct="{format-number($r4 div $n * 100,'0.00')}%"/>
      <mas_30d      count="{$r5}" pct="{format-number($r5 div $n * 100,'0.00')}%"/>
    </categoria>
  }
  </q22_distribucion_rangos_resolucion>

return
<bloque5b_resolucion>
  {$q21}
  {$q22}
</bloque5b_resolucion>
