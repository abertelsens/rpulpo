// =================================================================
// TYPST TEMPLATE FOR VELAS AL SANTISIMO
// =================================================================

//Pages settings, margins and footer.
#set page("a4", 
margin: (top:2cm, bottom:2cm, x:3cm)
)
//Defines the style of the heading of the document
#show heading: it => {
  set block(below: 20pt)
  set text(weight: "regular")
  align(center, smallcaps(it))
}

#set par(justify: true, first-line-indent: 0cm)

//CONTENTS
