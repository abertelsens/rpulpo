#let date = "$$date$$"
#let rector = "(rev. Fernando Crovetto Posse)"

#let show_date(date) = block(
  above:40pt, 
  width:100%, 
  text([#align(right, [Roma, #date])])
)

#let show_signature(rector) = { 
pad(x:7cm, y: 2cm)[
#box(
  width: 200pt,
)[#align(center,rector)]]
}

#set text(
  size: 13pt
)

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:5cm, bottom:3cm, x:3cm),
header: [
  #pad(x:-1.5cm, y: 1.3cm)[ 
    #box(width: 300pt)[
      #text(size: 15pt, weight: 500, [COLLEGIO ROMANO DELLA SANCTA CROCE]) 
      #align(center, text(baseline: -.8em, size: 11pt, [Via di Grottarossa 1375 - Roma 00189]))
    ]
  ]
],
footer: []
)


#set par(justify: true, first-line-indent: 1.5cm)

#v(-1cm)

//CONTENTS

Spett.le \
Ufficio Anagrafico \
Municipio n. XV \
Comune di Roma


#show_date[#date]

Il sottoscritto rev. Fernando Crovetto Posse, nato a Getxo (Spagna) il 6 gennaio 1976, dirigente della convivenza anagrafica denominata “Centro Internazionale Cavabianca” (Collegio Romano della Santa Croce), sita in Via di Grottarossa n. 1375, codice convivenza 32323803,

\
#align(center)[d i c h i a r a]
\

che il sig. $person.family_name.upcase$ $person.first_name$, di nazionalità $permits.citizenship$, nato il $person.birth$, residente in Via di Grottarossa n. 1375, fa parte della suddetta convivenza.


#show_signature[#rector]