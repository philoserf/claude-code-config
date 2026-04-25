#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

#set table(
  inset: 6pt,
  stroke: none
)

#show figure.where(
  kind: table
): set figure.caption(position: $if(table-caption-position)$$table-caption-position$$else$top$endif$)

#show figure.where(
  kind: image
): set figure.caption(position: $if(figure-caption-position)$$figure-caption-position$$else$bottom$endif$)

$if(highlighting-definitions)$
// syntax highlighting functions from skylighting:
$highlighting-definitions$

$endif$
$if(template)$
#import "$template$": conf
$else$
$template.typst()$
$endif$

$if(smart)$
$else$
#set smartquote(enabled: false)

$endif$
$for(header-includes)$
$header-includes$

$endfor$
#show: doc => conf(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(author)$
  authors: (
$for(author)$
$if(author.name)$
    ( name: [$author.name$],
      affiliation: [$author.affiliation$],
      email: [$author.email$] ),
$else$
    ( name: [$author$],
      affiliation: "",
      email: "" ),
$endif$
$endfor$
    ),
$endif$
$if(keywords)$
  keywords: ($for(keywords)$$keywords$$sep$,$endfor$),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(abstract-title)$
  abstract-title: [$abstract-title$],
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
$if(thanks)$
  thanks: [$thanks$],
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(mathfont)$
  mathfont: ($for(mathfont)$"$mathfont$",$endfor$),
$endif$
$if(codefont)$
  codefont: ($for(codefont)$"$codefont$",$endfor$),
$endif$
$if(linestretch)$
  linestretch: $linestretch$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
  pagenumbering: $if(page-numbering)$"$page-numbering$"$else$none$endif$,
$if(linkcolor)$
  linkcolor: [$linkcolor$],
$endif$
$if(citecolor)$
  citecolor: [$citecolor$],
$endif$
$if(filecolor)$
  filecolor: [$filecolor$],
$endif$
  cols: $if(columns)$$columns$$else$1$endif$,
  doc,
)

// --- Custom template tweaks ---
$if(subtitle)$
#set page(
  paper: "us-letter",
  margin: (x: 0.85in, y: 1.0in),
  header: align(right)[
    #text(size: 8pt, fill: gray)[
      $subtitle$
    ]
  ],
)
$else$
$if(title)$
#set page(
  paper: "us-letter",
  margin: (x: 0.85in, y: 1.0in),
  header: align(right)[
    #text(size: 8pt, fill: gray)[
      $title$
    ]
  ],
)
$else$
#set page(
  paper: "us-letter",
  margin: (x: 0.85in, y: 1.0in),
)
$endif$
$endif$

#show raw.where(block: true): block.with(
  fill: rgb("#f5f5f5"),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
)
#show raw: set text(font: "SF NS Mono", size: 9pt)

#set text(
  font: "New York",
  size: 10pt,
  lang: "en",
)
#show heading: set text(font: "SF NS", weight: "semibold")
// --- End custom tweaks ---

$for(include-before)$
$include-before$

$endfor$
$if(toc)$
#outline(
  title: auto,
  depth: $toc-depth$
);
$endif$

$body$

$if(citations)$
$for(nocite-ids)$
#cite(label("${it}"), form: none)
$endfor$
$if(csl)$

#set bibliography(style: "$csl$")
$elseif(bibliographystyle)$

#set bibliography(style: "$bibliographystyle$")
$endif$
$if(bibliography)$

#bibliography(($for(bibliography)$"$bibliography$"$sep$,$endfor$)$if(full-bibliography)$, full: true$endif$)
$endif$
$endif$
$for(include-after)$

$include-after$
$endfor$
