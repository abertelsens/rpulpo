#let date = "$$date$$"
#let impreso = "S11a"
#let registro = "Reg. crsc  Lib........... Pag...........  N..........."

#let show_date(date) = block(
  above:20pt, 
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
footer: [#pad(x:-2.3cm, y: .3cm, text(size: 9pt, [#registro \ \ #impreso]))]
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

TESTATUR AC FIDEM FACIT sequentes huius Praelaturae clericos Ordinem Diaconatus exercuisse et vacasse cursui recessus spiritualis, iure praescripto, ad Presbyteratum recipiendum:

#move(
dx: 100pt,
"$person.full_name$"
)
#show_date[#date]
