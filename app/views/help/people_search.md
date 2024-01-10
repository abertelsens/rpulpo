# Búsqueda de Personas

El campo de búsqueda funciona de modo similar a otras aplicaciones. Para buscar por `nombre` o `apellido` basta teclear en el campo el texto que se quiera buscar. Por ejemplo `alejandro` buscará a todas las personas con** nombre y apellido** que contengan "alejandro". Las máyusculas son ignoradas: `Alejandro`, `ALEJANDRO` o `Alejandro` dan el mismo resultado.

Si se quiere buscar por** otros campos** estos se deben especificar. Por ejemplo `group:1` buscará todas las personas que pertenecen al grupo 1. No hace falta escribir espacios después de los dos puntos, pero tampoco pasa nada si se hace. El nombre del campo debe estar bien escrito, si no el programa no es capaz de entender lo que se quiere, por ejempo `grup:1` no dará ningún resultado porque no existe un campo llamado `grup`.

Para facilitar las búsquedas se ofrecen varias alterativas, por ejemplo `year:1` o `año:1` son equivalentes. Se pueden ver todas las alternativas (*aliases*) en la tabla más abajo.

Los campos que contienen **fechas** como `arrival` (fecha de llegada al crs+) se buscan por año. Es decir `arrival:2023` entregará una lista de todas las personas que han llegado en el año 2023.

Hay algunos **campo de tipo numérico**, por ejemplo `ctr` puede contener cuatro valores: 0 - cavabianca, 1 - ctr dependiente, 2 no ha llegado, 3 se ha ido. Por ejemplo `ctr:0` entregará todos los que viven en cavabianca. Para hacer más fáciles estas búsquedas se pueden utilizar *aliases*. Por ejemplo si se escribe `cb` en el campo de búsqueda, pulpo entenderá que la búsqueda en realidad es `ctr:0`. De forma similar`dep` se traducirá por `ctr:1` y entregará la lista de los que viven en ctr dependientes. Ver tablas *query aliases* más abajo para todas las posibilidades.

## Lista de campos y posibilidades para nombrarlos:

| Campo | Type | Descripción | Aliases |
| ---- | ---- | ---- | ---- |
| family_name | string |  | apellido |
| first_name | string |  | nombre |
| short_name | string | nombre corto que usa habitualmente |  |
| full_name | string | nombre completo con todos los nombre y apellidos |  |
| group | string | grupo al que pertenece | grupo |
| status | integer | Tres posibilidades: 0 - laico, 1 - diácono, 2 - sacerdote |  |
| n_agd | integer | Si es n o ag. e. Puede contener dos valores: 0 - n, 1 - agd | n, agd |
| ctr | integer | ctr en el que vive. Puede contener cuatro valores: 0 - cavabianca, 1 - ctr dependiente, 2 no ha llegado, 3 se ha ido | centro, center |
| year | date | año en el crs+ | año |
| clothes | string |  | ropa, número, numero, num |
| arrival | date | fecha de llegada al crs+ | llegada |
| departure | date | fecha de salida del crs+ | salida |
| birth | date | fecha de nacimiento | cumple, cumpleaños |
| email | string |  |  |
| phone | string |  | tel |
| celebration_info | string | información sobre el día que celebra |  |
| room | string | nombre de la habitación | habitación, hab |

## Query aliases



family_name: apellido
first_name: 
short_name:
people.full_name"
group"
status"
people.n_agd"
people.ctr"
year"
clothes"
arrival"
departure"
birth"
email"
phone"
celebration_info"

region"
    name: "region"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "personals.region_of_origin"
    name: "Region of Origin"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "studies.faculty"
    name: "faculty"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "studies.year_of_studies"
    name: "Year"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "studies.status"
    name: "Estudios Inst."
    type: "string"
    order: "NONE"
    css_class: "long-field"
  - id: "studies.licence"
    name: "licence"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "studies.doctorate"
    name: "doctorate"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.room"
    name: "room name"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.house"
    name: "house"
    type: "enum"
    order: "NONE"
    css_class: "long-field"
  - id: "rooms.floor"
    name: "floor"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.bed"
    name: "bed"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.matress"
    name: "matress"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.bathroom"
    name: "bathroom"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "rooms.phone"
    name: "phone"
    type: "string"
    order: "NONE"
    css_class: "medium-field"
  - id: "personals.classnumber"
    name: "promoción"
    type: "string"
    order: "NONE"
    css_class: "short-field u-text-center"
  - id: "crs.admissio"
    name: "admissio"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.pa"
    name: "pa"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.admision"
    name: "admisión"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.oblacion"
    name: "oblación"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.fidelidad"
    name: "fidelidad"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.letter"
    name: "carta"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.lectorado"
    name: "lectorado"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.acolitado"
    name: "acolitado"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.diaconado"
    name: "diaconado"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.presbiterado"
    name: "presbiterado"
    type: "date"
    order: "NONE"
    css_class: "medium-field"
  - id: "crs.cipna"
    name: "cipna"
    type: "string"
    order: "NONE"
    css_class: "medium-field"

## Concatenación de Búsquedas

Si se especifican dos o más criterios, por default **PULPO** concatena las búsquedas con un operador `or`. Por ejemplo `group:2 year:1` buscará todos las personas que están en el grupo 2 o en el año 1. Si se quiere utilizar el operador `and` se debe especificad, i.e. `group:2 AND year:1` en mayúsculas o minúsculas `group:2 AND year:1` o `group:2 and year:1` son equivalentes.