#let impreso = "C38"

#let show_header(name) = grid.cell( inset:(y:.8em), colspan: 5, text(size:18pt, weight:700, font: "Source Serif Pro")[#name]) 

#let show_picture() = figure(
  image("app/public/photos/$person.id$.jpg", width:3cm))
  
#let show_picture() = place(
  top + left,
  figure(
  image("../../public/photos/$person.id$.jpg", width:3.4cm)
  ),
)

#let label(c, t) = grid.cell(colspan: c, text(fill: rgb(6, 64, 156), weight: 600, font:"Source Serif Pro")[#t])
#let field(c, t) = grid.cell( colspan: c, text(weight: 500, font:"Source Serif Pro")[#t])

  
//Pages settings, margins and footer.
#set page("a5",
flipped: true,
margin: (top:1cm, bottom:1.5cm, x:1cm),
header: [#pad(x:0cm, y: -.2cm, align(right, text(size: 10pt, weight: "bold", fill: rgb(6, 64, 156), smallcaps("Colegio Romano de la Santa Cruz"))))],
footer: [#pad(x:0cm, y: 0cm, text(size: 8pt, [#impreso]))]
)

#grid(
  columns: (22%, 12%, 18%, 18%, 10%, 10%),
  gutter: 10pt,
  row-gutter: 1.6em,
  show_picture(),
  show_header("$person.full_name$"),
  "",
  label(2,"Alumno del Colegio desde"),
  field(1,"$person.arrival$"),
  label(1,"hasta"),
  field(1,"$person.departure$"),
  "",
  label(2,"Promoción No."),
  field(3,"$crs_records.classnumber$"),
  "",
  label(2,"Región de Origen"),
  field(1,"$personals.region_of_origin$"),
  label(1,"Región"),
  field(1,"$personals.region$"),
  "",
  label(2,"Lugar y Fecha de Nacimiento"),
  field(3, "$personals.city$, $person.birth$"),
  label(1,"Estudios Institucionales"),
  field(5, "$studies.status$"),
  label(1,"Estudios Civiles"),
  field(5, "$studies.civil_studies$"),
  label(1,"Facultad Eclesiástica"),
  field(1, "$studies.faculty$"),
  label(1,"Licenciatura"),
  field(1, "$studies.licence$"),
  label(1,"Doctorado"),
  field(1, "$studies.doctorate$"),
  label(1,"Tesis Doctoral"),
  field(5, "$studies.thesis$"),
  label(1,"Idiomas"),
  field(5, "$personals.languages$"),
  label(1,"Pidió la Admisión"),
  field(1, "$crs_records.pa$"),
  label(1,"Hizo la Oblación"),
  field(3, "$crs_records.oblacion$"),
  label(1,"Hizo la Admisión"),
  field(1, "$crs_records.admision$"),
  label(1,"Hizo la Fidelidad"),
  field(1,  "$crs_records.fidelidad$"),
)
#pagebreak()
#v(2em)
#grid(
  columns: (22%, 12%, 18%, 18%, 10%, 10%),
  gutter: 10pt,
  row-gutter: 1.5em,
  label(2,"Ha manifestado su disposición de ser sacerdote"),
  field(1,"$crs_records.letter$"),
  label(2,"Hizo la Admissio"),
  field(1,"$crs_records.admissio$"),
  label(2,"Recibió el Lectorado"),
  field(1,"$crs_records.lectorado$"),
  label(2,"Recibió el Acolitado"),
   field(1,"$crs_records.acolitado$"),
  label(2,"Ordenado Diácono"),
  field(1,"$crs_records.diaconado$"),
  label(2,"Ordenado Sacerdote"),
  field(1,"$crs_records.presbiterado$"),
  label(6,"Datos y Circunstacias Familiares"),
  "",
  field(5,"Padres: $personals.father_name$ y $personals.mother_name$"),
  "",
  field(5,"Domicilio: $personals.parents_address$"),
  "",
  field(5,"$personals.siblings_info$"),
  "",
  field(5,"$personals.parents_info$"),
  "",
  field(5,"$personals.parents_work$"),
  "",
  field(5,"$personals.economic_info$"),
  label(1,"Antecedentes Médicos"),
  field(5,"$personals.medical_info$"),
  label(1,"Observaciones"),
  field(5,"Celebra $person.celebration_info$ \n$studies.profesional_experience$ \n$personals.notes$")
)
