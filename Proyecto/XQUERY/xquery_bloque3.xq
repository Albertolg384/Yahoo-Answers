(:
  ================================================================
  BLOQUE 3 - ANALISIS CROSS-CATEGORIA 
  
  Cambio respecto a una version anterior lenta:
  Q11 usa los IDs del top-50 ya conocidos de Q10 (hardcoded),
  evitando el doble GROUP BY + db:text anidado que tardaba minutos.
  Q12 y Q13 usan distinct-values sobre subcats con filtro >= 500.
  
  ================================================================
:)

let $sci_mc := ("Science &amp; Mathematics","Ciencia y Matemáticas","Ciências e Matemática",
                "Sciences et mathématiques","Wissenschaft &amp; Mathematik")
let $edu_mc := ("Education &amp; Reference","Educación","Educación y Formación",
                "Educação e Referência","Enseignement et référence",
                "Scuola ed educazione","Schule &amp; Bildung")
let $soc_mc := ("Social Science","Ciencias Sociales","Ciencias sociales",
                "Sciences sociales","Sozialwissenschaft","Scienze sociali","Ciências Sociais")
let $art_mc := ("Arts &amp; Humanities","Arte y Humanidades","Artes e Humanidades",
                "Arts et sciences humaines","Kunst &amp; Geisteswissenschaft","Arte e cultura")

(: Top-50 IDs y su categoria dominante, extraidos de Q10 :)
(: Formato: (id, cat_dominante) :)
let $top50_perfiles := (
  ("u483503","edu"),("u1375495","edu"),("u1729248","art"),("u355509","sci"),
  ("u1694623","edu"),("u26770","sci"),("u893686","sci"),("u278952","sci"),
  ("u353770","sci"),("u1499243","sci"),("u1495573","sci"),("u1551571","sci"),
  ("u27241","edu"),("u854180","sci"),("u1123890","sci"),("u1642854","sci"),
  ("u154815","sci"),("u738948","art"),("u1202732","sci"),("u1108774","edu"),
  ("u1059985","art"),("u1305120","sci"),("u127797","edu"),("u1727389","soc"),
  ("u1502951","edu"),("u291023","edu"),("u462320","edu"),("u1566570","edu"),
  ("u1236970","sci"),("u621287","sci"),("u98396","sci"),("u1508926","soc"),
  ("u1036634","sci"),("u599183","art"),("u1135849","sci"),("u73875","edu"),
  ("u1765850","sci"),("u1797838","sci"),("u1344779","sci"),("u449978","edu"),
  ("u139380","sci"),("u270837","edu"),("u1217227","sci"),("u586959","edu"),
  ("u1156801","sci"),("u584965","edu"),("u649422","edu"),("u705727","sci"),
  ("u102019","edu"),("u152271","sci")
)

(: Q11: RESPUESTAS FUERA DE CATEGORIA DOMINANTE (top-50) :)
(: Para cada top-50, sus respuestas elegidas fuera de su cat. dominante :)
let $q11 :=
  <q11_cross_categoria_top50>
    <descripcion>Respuestas elegidas fuera de la categoria dominante del respondedor (top-50)</descripcion>
    <resumen>
    {
      let $pares :=
        for $i in 1 to count($top50_perfiles) idiv 2
        let $uid     := $top50_perfiles[($i*2)-1]
        let $cat_dom := $top50_perfiles[$i*2]
        let $regs    := db:text("yahoo_answers",$uid)/parent::best_id/parent::document/parent::vespaadd
        let $mcs     := $regs/document/maincat/string()
        let $en_dom  := if ($cat_dom="sci") then count($mcs[. = $sci_mc])
                        else if ($cat_dom="edu") then count($mcs[. = $edu_mc])
                        else if ($cat_dom="soc") then count($mcs[. = $soc_mc])
                        else count($mcs[. = $art_mc])
        let $total   := count($regs)
        let $fuera   := $total - $en_dom
        return ($total, $en_dom, $fuera)

      let $total_resp := sum($pares[position() mod 3 = 1])
      let $en_dom_sum := sum($pares[position() mod 3 = 2])
      let $fuera_sum  := sum($pares[position() mod 3 = 0])
      return
      <estadisticas>
        <total_respuestas_top50>{$total_resp}</total_respuestas_top50>
        <en_categoria_dominante>{$en_dom_sum}</en_categoria_dominante>
        <fuera_categoria_dominante>{$fuera_sum}</fuera_categoria_dominante>
        <pct_cross>{format-number($fuera_sum div $total_resp * 100,'0.00')}%</pct_cross>
      </estadisticas>
    }
    </resumen>
    <detalle_por_respondedor>
    {
      for $i in 1 to count($top50_perfiles) idiv 2
      let $uid     := $top50_perfiles[($i*2)-1]
      let $cat_dom := $top50_perfiles[$i*2]
      let $regs    := db:text("yahoo_answers",$uid)/parent::best_id/parent::document/parent::vespaadd
      let $mcs     := $regs/document/maincat/string()
      let $sci_n   := count($mcs[. = $sci_mc])
      let $edu_n   := count($mcs[. = $edu_mc])
      let $soc_n   := count($mcs[. = $soc_mc])
      let $art_n   := count($mcs[. = $art_mc])
      let $en_dom  := if ($cat_dom="sci") then $sci_n
                      else if ($cat_dom="edu") then $edu_n
                      else if ($cat_dom="soc") then $soc_n
                      else $art_n
      let $total   := count($regs)
      let $fuera   := $total - $en_dom
      order by $fuera descending
      return
      <respondedor id="{$uid}" cat_dom="{$cat_dom}" total="{$total}"
                   en_dom="{$en_dom}" fuera="{$fuera}"
                   pct_fuera="{format-number($fuera div $total * 100,'0.0')}%"/>
    }
    </detalle_por_respondedor>
  </q11_cross_categoria_top50>

(: Q12: SUBCATEGORIAS CON MAS RESPONDEDORES UNICOS :)
(: Solo subcats con >= 500 preguntas para limitar iteraciones :)
let $all_subcats := distinct-values(
  db:get("yahoo_answers")/yahooAnswers/vespaadd/document/subcat[. != '']
)

let $q12 :=
  <q12_diversidad_respondedores_por_subcat>
    <descripcion>Top 15 subcategorias por numero de respondedores unicos (min 500 preguntas)</descripcion>
  {
    subsequence(
      for $sc in $all_subcats
      let $regs   := db:text("yahoo_answers",$sc)/parent::subcat/parent::document/parent::vespaadd
      let $n_preg := count($regs)
      where $n_preg >= 500
      let $n_uid  := count(distinct-values($regs/document/best_id[. != '']))
      let $ratio  := format-number($n_uid div $n_preg,'0.000')
      order by $n_uid descending
      return
      <subcat nombre="{$sc}" preguntas="{$n_preg}"
              respondedores_unicos="{$n_uid}" ratio_diversidad="{$ratio}"/>
    , 1, 15)
  }
  </q12_diversidad_respondedores_por_subcat>

(: Q13: SUBCATEGORIAS MAS "DEMOCRATICAS" (mayor ratio diversidad) :)
(: Subcats donde el mayor numero de usuarios distintos participa
   respecto al total de preguntas = nadie domina :)
let $q13 :=
  <q13_subcategorias_mas_democraticas>
    <descripcion>Top 15 subcategorias con mayor ratio respondedores_unicos/preguntas (min 500 preg.)</descripcion>
  {
    subsequence(
      for $sc in $all_subcats
      let $regs   := db:text("yahoo_answers",$sc)/parent::subcat/parent::document/parent::vespaadd
      let $n_preg := count($regs)
      where $n_preg >= 500
      let $n_uid  := count(distinct-values($regs/document/best_id[. != '']))
      let $ratio  := $n_uid div $n_preg
      order by $ratio descending
      return
      <subcat nombre="{$sc}" preguntas="{$n_preg}"
              respondedores_unicos="{$n_uid}"
              ratio="{format-number($ratio,'0.000')}"/>
    , 1, 15)
  }
  </q13_subcategorias_mas_democraticas>

return
<bloque3_cross_categoria>
  {$q11}
  {$q12}
  {$q13}
</bloque3_cross_categoria>
