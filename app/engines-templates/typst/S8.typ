#let date = "$$date$$"
#let impreso = "S8"
#let registro = "Reg. crsc  Lib........... Pag...........  N..........."

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

ad normam can. 1051, 1) CIC, TESTATUR AC FIDEM FACIT, graviter onerata conscientia, candidatum ad Presbyteratum D.num $person.first_name$ $person.family_name$ exemplariter se gessisse et omnibus praeditum esse qualitatibus tum moralibus et intellectualibus tum ad animi indolem pertinentibus, quae ad statum clericalem requiruntur,
itemque, ad normam can. 1040 CIC, non constare eum affectum esse irregularitatibus in can. 1041 CIC praevisis vel impedimentis in can. 1042 CIC statutis.


#show_date[#date]