(:
  BLOQUE 5A - Q19 y Q20: Evolucion temporal (solo campo date)
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

(: Funcion auxiliar: convierte timestamp Unix a anho y mes :)
(: Usamos let explicito dentro del FOR para anclar el contexto :)

let $q19 :=
  <q19_evolucion_mensual_2005_2007>
    <descripcion>Numero de preguntas por mes (2005-2007)</descripcion>
  {
    for $rec in $all
    let $ts_str := string(($rec/document/date[. != ''])[1])
    where $ts_str != ''
    let $ts   := xs:integer($ts_str)
    let $dias := floor($ts div 86400)
    let $anho := 1970 + xs:integer(floor($dias div 365.25))
    let $mes  := xs:integer(floor($dias mod 365.25 div 30.4375)) + 1
    where $anho = 2005 or $anho = 2006 or $anho = 2007
    group by $a := $anho, $m := $mes
    order by $a, $m
    return <mes anho="{$a}" mes="{$m}" preguntas="{count($rec)}"/>
  }
  </q19_evolucion_mensual_2005_2007>

let $q20 :=
  <q20_mes_mayor_actividad>
  {
    let $global :=
      for $rec in $all
      let $ts_str := string(($rec/document/date[. != ''])[1])
      where $ts_str != ''
      let $ts   := xs:integer($ts_str)
      let $dias := floor($ts div 86400)
      let $anho := 1970 + xs:integer(floor($dias div 365.25))
      let $mes  := xs:integer(floor($dias mod 365.25 div 30.4375)) + 1
      group by $a := $anho, $m := $mes
      order by count($rec) descending
      return <mes anho="{$a}" mes="{$m}" preguntas="{count($rec)}"/>
    return <top5_global>{ subsequence($global, 1, 5) }</top5_global>
  }
  {
    for $cat_name in ("Science and Mathematics","Education and Reference","Social Science","Arts and Humanities")
    let $mc := if ($cat_name = "Science and Mathematics") then $sci_mc
               else if ($cat_name = "Education and Reference") then $edu_mc
               else if ($cat_name = "Social Science") then $soc_mc
               else $art_mc
    let $top :=
      for $rec in $all[document/maincat = $mc]
      let $ts_str := string(($rec/document/date[. != ''])[1])
      where $ts_str != ''
      let $ts   := xs:integer($ts_str)
      let $dias := floor($ts div 86400)
      let $anho := 1970 + xs:integer(floor($dias div 365.25))
      let $mes  := xs:integer(floor($dias mod 365.25 div 30.4375)) + 1
      group by $a := $anho, $m := $mes
      order by count($rec) descending
      return <mes anho="{$a}" mes="{$m}" preguntas="{count($rec)}"/>
    return
    <top1_categoria nombre="{$cat_name}">{ subsequence($top, 1, 1) }</top1_categoria>
  }
  </q20_mes_mayor_actividad>

return
<bloque5a_temporal>
  {$q19}
  {$q20}
</bloque5a_temporal>
