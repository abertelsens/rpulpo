// =================================================================
// TYPST TEMPLATE FOR IMPRESO F28
// =================================================================
// The template has two parts. A preamble in which we define some variables, 
// functions to be used and some settings of the document.

// =================================================================
// VARIABLES
// =================================================================
// Pulpo will prompt the user to set the values of the variables that are      
// enclosed in $ signs.

#let impreso = "F28"
#let date = "$$date$$"

//=================================================================
//FUNCTIONS 
//=================================================================
#let show_date(date) = block(
  above:40pt,
  width:100%,
  text([#align(right, date)])
)

//Defines the style of the heading of the document
#show heading: it => {
  set block(below: 30pt)
  set text(weight: "regular")
  align(center, smallcaps(it))
}

// =================================================================
// PAGE SETTINGS, MARGINS AND BORDERS
// =================================================================

#set page("a4",
margin: (top:6cm, bottom:3cm, x:3cm),
footer: [#pad(x:-2.3cm, y: 1.2cm, text(size: 9pt, [#impreso]))]
)

#set text(
  font: "Minion Pro",
  size: 13pt
)


#set par(justify: true, first-line-indent: 0cm)


//CONTENTS

= IUISUIURANDUM FIDELITATIS IN SUSCIPIENDO \ OFFICIO NOMINE ECCLESIAE EXERCENDO

Ego $person.first_name$ $person.family_name$ in suscipiendo ordine Presbiteratus promitto me cum catholica Ecclesia communionem semper servaturum, sive verbis a me prolatis, sive mea agendi ratione.

Magna cum diligentia et fidelitate onera explebo quibus teneor erga Ecclesiam, tum universam, tum particularem, in qua ad meum servitium, secundum iuris praescripta, exercendum vocatus sum.

In munere meo adimplendo, quod Ecclesiae nomine mihi commissum est, fidei depositum integrum servabo, fideliter tradam et illustrabo; quascumque igitur doctrinas iisdem contrarias devitabo.

Disciplinam cunctae Ecclesiae communem sequar et fovebo observantiamque cunctarum legum ecclesiasticarum, earum imprimis quae in Codice Iuris Canonici continentur, servabo.

Christiana oboedientia prosequar quae sacri Pastores, tamquam authentici fidei doctores et magistri declarant aut tamquam Ecclesiae rectores statuunt, atque Episcopis dioecesanis fideliter auxilium dabo, ut actio apostolica, nomine et mandato Ecclesiae exercenda, in eiusdem Ecclesiae communione peragatur.

Sic me Deus adiuvet et sancta Dei Evangelia, quae manibus meis tango.

#show_date[#date]