#let date = "$$date$$"
#let impreso = "S6"

#let show_date(date) = block(
  above:40pt, 
  width:100%, 
  text([#align(right, [#date])])
)

#set text(
  size: 13pt
)

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:5cm, bottom:3cm, x:3cm),
header: [#pad(x:-1.5cm, y: 1.3cm, text(size: 15pt, weight: 500, [COLLEGIUM ROMANUM SANCTAE CRUCIS]))],
footer: [#pad(x:-2.3cm, y: .9cm, text(size: 9pt, [#impreso]))]
)

//Defines the style of the heading of the document
#show heading: it => {
  set block(below: 30pt)
  set text(weight: "regular")
  align(center, smallcaps(it))
}

#set par(justify: true, first-line-indent: 0cm)

//CONTENTS

Infrascriptus Dr. Ferdinando Crovetto, Collegii Romani Sanctae Crucis Rector,

TESTATUR AC FIDEM FACIT se, iuxta facultatem sibi ab Rev.mo Domino Ferdinando Ocáriz, Praelato Sanctae Crucis et Operis Dei concessam, contulisse D.no $person.first_name$ $person.family_name$ huius Praelaturae fideli, prius Ministerium Lectoris, $crs.lectorado.latin$, posteaque Acolythi, $crs.acolitado.latin$.

#show_date[#date]