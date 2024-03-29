#let date = "$$date$$"
#let impreso = "S6"

#let show_date(date) = block(
  above:40pt, 
  width:100%, 
  text([#align(right, [#date])])
)

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:5cm, bottom:3cm, x:3cm),
header: [#pad(x:-1.5cm, y: 1.5cm, text(size: 15pt, [COLLEGIUM ROMANUM SANCTAE CRUCIS]))],
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

TESTATUR AC FIDEM FACIT, iuxta facultates ab Rev.mo Domino Ferdinando Ocáriz, Praelato Sanctae Crucis et Operis Dei concessas, D.no $person.first_name$ $person.family_name$ huius Praelaturae fideli, collatum esse Ministerium Acolythi, $crs.acolitado.latin$.

#show_date[#date]