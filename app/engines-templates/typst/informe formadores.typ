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

#let date_meeting = "$$date of meeting$"
#let date = "$$date2$$"
//=================================================================
//FUNCTIONS 
//=================================================================
#let show_date(date) = block(
  above:40pt, 
  width:100%, 
  text([#align(right, [#date])])
)

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:5cm, bottom:3cm, x:3cm),
header: [#pad(x:-1.5cm, y: 1.5cm, text(size: 15pt, [COLLEGIUM ROMANUM SANCTAE CRUCIS]))]
)

#set text(12pt)

#set par(
  first-line-indent: 3em,
  justify: true,
)

//CONTENTS

En sesión colegial del $$date of meeting$$ el Consejo de formadores del Colegio Romano de la Santa Cruz emitió parecer positivo acerca de la idoneidad para recibir las órdenes sagradas del Diaconado y del Presbiterado del candidato $person.first_name$ $person.family_name$.

#v(60pt)

#table(
  columns: (auto, auto),
  inset: (x:66pt, y:60pt),
  stroke: none,
  align: center,
  [Formador], [Formador],
  [Formador], [Director de Estudios],
  [Vicerrector], [Rector]
)

#v(40pt)  

#show_date[#date]