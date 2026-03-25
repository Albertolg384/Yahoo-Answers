(:
  ================================================================
  BLOQUE 2 - ANALISIS DE REDES SOCIALES (VERSION UNIFICADA)
  Proyecto: Trabajo XML - Bases de Datos Avanzadas
  Autores:  Alberto Lillo Garcia y Manuel Caballero Bonilla

  TECNICAS CLAVE:
  - GROUP BY XQuery 3.1: agrupacion en un unico paso O(n)
  - Rutas explicitas child-step: evita traversal // sobre todo el arbol
  - subsequence(): limite correcto de resultados en FLWOR
  - db:text(): lookup O(log n) por ID para Q9 y Q10
  - Los IDs del top 50 de Q5 fluyen automaticamente a Q9 y Q10
  ================================================================
:)

(: LECTURA BASE: rutas explicitas, sin // :)
let $all_best_id :=
  db:get("yahoo_answers")/yahooAnswers/vespaadd/document/best_id[. != '']
let $all_id :=
  db:get("yahoo_answers")/yahooAnswers/vespaadd/document/id[. != '']

(: AGRUPACION CENTRAL: un unico GROUP BY para best_id :)
(: Se calcula una vez y se reutiliza en Q5, Q7, Q9, Q10 :)
let $resp_grouped :=
  subsequence(
    for $v in $all_best_id
    group by $uid := string($v)
    order by count($v) descending
    return <u id="{$uid}" n="{count($v)}"/>
  , 1, 50)

(: AGRUPACION CENTRAL: un unico GROUP BY para id :)
let $preg_grouped :=
  subsequence(
    for $v in $all_id
    group by $uid := string($v)
    order by count($v) descending
    return <u id="{$uid}" n="{count($v)}"/>
  , 1, 200)

(: IDs extraidos automaticamente — sin sustitucion manual :)
let $top10_ids := subsequence($resp_grouped, 1, 10)/@id/string()
let $top50_ids := $resp_grouped/@id/string()
let $ids_preg  := $preg_grouped/@id/string()

(: Variantes de maincat por categoria canonica :)
let $sci_mc := ("Science &amp; Mathematics","Ciencia y Matemáticas","Ciências e Matemática",
                "Sciences et mathématiques","Wissenschaft &amp; Mathematik")
let $edu_mc := ("Education &amp; Reference","Educación","Educación y Formación",
                "Educação e Referência","Enseignement et référence",
                "Scuola ed educazione","Schule &amp; Bildung")
let $soc_mc := ("Social Science","Ciencias Sociales","Ciencias sociales",
                "Sciences sociales","Sozialwissenschaft","Scienze sociali","Ciências Sociais")
let $art_mc := ("Arts &amp; Humanities","Arte y Humanidades","Artes e Humanidades",
                "Arts et sciences humaines","Kunst &amp; Geisteswissenschaft","Arte e cultura")

(: Q5: TOP 20 RESPONDEDORES :)
let $q5 :=
  <q5_top20_respondedores>
  {
    for $u in subsequence($resp_grouped, 1, 20)
    return <respondedor id="{$u/@id}" respuestas_elegidas="{$u/@n}"/>
  }
  </q5_top20_respondedores>

(: Q6: TOP 20 PREGUNTADORES :)
let $q6 :=
  <q6_top20_preguntadores>
  {
    for $u in subsequence($preg_grouped, 1, 20)
    return <preguntador id="{$u/@id}" preguntas_formuladas="{$u/@n}"/>
  }
  </q6_top20_preguntadores>

(: Q7: USUARIOS BIDIRECCIONALES (top 200 en ambos roles) :)
let $q7 :=
  <q7_usuarios_bidireccionales>
    <descripcion>Usuarios en top-200 respondedor Y top-200 preguntador simultaneamente</descripcion>
  {
    for $uid in $resp_grouped[position() le 200]/@id/string()
    where $uid = $ids_preg
    let $n_r := xs:integer($resp_grouped[@id = $uid]/@n)
    let $n_p := xs:integer($preg_grouped[@id = $uid]/@n)
    order by ($n_r + $n_p) descending
    return
    <usuario id="{$uid}">
      <respuestas_elegidas>{$n_r}</respuestas_elegidas>
      <preguntas_formuladas>{$n_p}</preguntas_formuladas>
      <actividad_total>{$n_r + $n_p}</actividad_total>
    </usuario>
  }
  </q7_usuarios_bidireccionales>

(: Q8: PARES (preguntador -> respondedor) MAS FRECUENTES :)
let $q8 :=
  <q8_pares_frecuentes>
    <descripcion>Pares usuario_pregunta — usuario_responde repetidos mas de 1 vez</descripcion>
  {
    subsequence(
      for $rec in db:get("yahoo_answers")/yahooAnswers/vespaadd[
        document/id[. != ''] and document/best_id[. != '']
      ]
      group by
        $asker    := string($rec/document/id),
        $answerer := string($rec/document/best_id)
      let $n := count($rec)
      where $n > 1
      order by $n descending
      return <par preguntador="{$asker}" respondedor="{$answerer}" veces="{$n}"/>
    , 1, 20)
  }
  </q8_pares_frecuentes>

(: Q9: CATEGORIA DOMINANTE TOP 10 RESPONDEDORES :)
(: IDs vienen automaticamente de $top10_ids (extraido de $resp_grouped) :)
let $q9 :=
  <q9_categoria_dominante_top10_respondedores>
    <descripcion>En que categoria concentra sus respuestas cada top-10 respondedor</descripcion>
  {
    for $uid in $top10_ids
    let $regs    := db:text("yahoo_answers",$uid)/parent::best_id/parent::document/parent::vespaadd
    let $n_total := count($regs)
    let $mcs     := $regs/document/maincat/string()
    let $sci_n   := count($mcs[. = $sci_mc])
    let $edu_n   := count($mcs[. = $edu_mc])
    let $soc_n   := count($mcs[. = $soc_mc])
    let $art_n   := count($mcs[. = $art_mc])
    let $cat_dom :=
      if ($sci_n >= $edu_n and $sci_n >= $soc_n and $sci_n >= $art_n)
      then "Science and Mathematics"
      else if ($edu_n >= $soc_n and $edu_n >= $art_n)
      then "Education and Reference"
      else if ($soc_n >= $art_n) then "Social Science"
      else "Arts and Humanities"
    return
    <respondedor id="{$uid}" total="{$n_total}" categoria_dominante="{$cat_dom}">
      <sci>{$sci_n}</sci><edu>{$edu_n}</edu><soc>{$soc_n}</soc><art>{$art_n}</art>
    </respondedor>
  }
  </q9_categoria_dominante_top10_respondedores>

(: Q10: GENERALISTAS VS ESPECIALISTAS TOP 50 :)
(: IDs vienen automaticamente de $top50_ids (extraido de $resp_grouped) :)
let $q10 :=
  <q10_generalistas_vs_especialistas>
    <descripcion>Top 50 respondedores: cuantas categorias distintas cubren con sus respuestas</descripcion>
  {
    for $uid in $top50_ids
    let $regs   := db:text("yahoo_answers",$uid)/parent::best_id/parent::document/parent::vespaadd
    let $n      := count($regs)
    let $mcs    := $regs/document/maincat/string()
    let $sci_n  := count($mcs[. = $sci_mc])
    let $edu_n  := count($mcs[. = $edu_mc])
    let $soc_n  := count($mcs[. = $soc_mc])
    let $art_n  := count($mcs[. = $art_mc])
    let $n_cats := count(($sci_n,$edu_n,$soc_n,$art_n)[. > 0])
    let $perfil := if ($n_cats = 1) then "especialista" else "generalista"
    order by $n descending
    return
    <respondedor id="{$uid}" total="{$n}" categorias="{$n_cats}" perfil="{$perfil}">
      <desglose sci="{$sci_n}" edu="{$edu_n}" soc="{$soc_n}" art="{$art_n}"/>
    </respondedor>
  }
  </q10_generalistas_vs_especialistas>

return
<bloque2_redes_sociales>
  {$q5}
  {$q6}
  {$q7}
  {$q8}
  {$q9}
  {$q10}
</bloque2_redes_sociales>
