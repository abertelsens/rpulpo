#let date = "$$date$$"
#let impreso = "S4"

#let show_date(date) = block(
  above:20pt, 
  width:100%, 
  text([#align(right, [#date])])
)

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:5cm, bottom:3cm, x:3cm),
header: [#pad(x:-1.5cm, y: 1.5cm, text(size: 15pt, [COLLEGIUM ROMANUM SANCTAE CRUCIS]))],
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

Infrascriptus Dr. Ferdinando Crovetto, Collegii Romani Sanctae Crucis Rector, iuxta facultatem sibi a Rev.mo Domino Ferdinando Ocáriz, Praelato Sanctae Crucis et Operis Dei concessam,

TESTATUR AC FIDEM FACIT sequentes huius Praelaturae fideles obligationes adquisisse quae ordinandorum sunt propriae:

#move(
dx: 100pt,
"$person.full_name$"
)

#show_date[#date]
