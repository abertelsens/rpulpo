// =================================================================
// TYPST TEMPLATE FOR IMPRESO F21
// =================================================================
// The template has two parts. A preamble in which we define some variables, 
// functions to be used and some settings of the document.

// =================================================================
// VARIABLES
// =================================================================
// Pulpo will prompt the user to set the values of the variables that are      
// enclosed in $ signs.


#let date = "$$date$$"
#let rector = "Fernando Crovetto\nRector"

//=================================================================
//FUNCTIONS 
//=================================================================
#let show_date(date) = block(
  above:40pt,
  width:100%,
  text([#align(right, date)])
)

#let show_signature(rector) = { 
pad(x:7cm, y: 4cm)[
#box(
  width: 200pt,
)[#align(center,rector)]]
}

//Defines the style of the heading of the document
#show heading: it => {
  set block(below: 30pt)
  set text(weight: "regular")
  align(center, smallcaps(it))
}

// =================================================================
// PAGE SETTINGS, MARGINS AND BORDERS
// =================================================================
#set text(
  size: 12pt
)

#set page("a4",
margin: (top:6cm, bottom:3cm, x:3cm),
header: [#pad(x:-1.5cm, y: 1.5cm, text(size: 15pt, [COLLEGIUM ROMANUM SANCTAE CRUCIS]))]
)

#set par(justify: true, first-line-indent: 0cm)


//CONTENTS

$person.first_name$ $person.family_name$ ha ejercido el Ministerio de Lectorado el tiempo previsto y ha alcanzado los objetivos de la etapa configuradora correspondiente. No hay nada relevante que añadir a lo señalado en el informe previo al Lectorado. Contando con el voto positivo de los formadores de este Colegio y la opinión positiva de personas con las que el candidato ha convivido y ha ejercido su trabajo apostólico, declaramos que reúne las cualidades necesarias para recibir el Ministerio del Acolitado.


#show_date[#date]
#show_signature[#rector]