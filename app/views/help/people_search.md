# Búsqueda de Personas

El campo de búsqueda funciona de modo similar a otras aplicaciones. Para buscar por `nombre` o `apellido` basta teclear en el campo el texto que se quiera buscar. Por ejemplo `alejandro` buscará a todas las personas con **nombre o apellido** que contengan "alejandro". Las máyusculas son ignoradas: `Alejandro`, `ALEJANDRO` o `Alejandro` dan el mismo resultado.

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
| student | boolean | si se considera alumno del crs+ | alumno |
| clothes | string |  | ropa, número, numero, num |
| arrival | date | fecha de llegada al crs+ | llegada |
| departure | date | fecha de salida del crs+ | salida |
| birth | date | fecha de nacimiento | cumple, cumpleaños |
| email | string |  |  |
| phone | string |  | tel |
| celebration_info | string | información sobre el día que celebra |  |
| room | string | nombre de la habitación | habitación, hab |

## Query Aliases

Se ofrecen algunos aliases para búsqueda más frecuentes. 

| Alias(es) | Query | Descripción |
| ---- | ---- | ---- |
| g1, g2, g3, g4, dir | `group:x` | Búsqueda de las personas pertenecientes al grupo especificado |
| sacerdotes, sacerdote, sacd | `status:2` | Búsqueda de todos los sacerdotes |
| diáconos, diaconos, diácono, diacono, diac  | `status:1` | Búsqueda de todos los diáconos |
| agd | `n_agd:1` |  Búsqueda de todos los agregados |
| laicos, laico | `status:0` | Búsqueda de todos los laicos |
| students, alumnos | `student:true` | Búsqueda de todos los alumnos del crs+ |
| cavabianca, cb | `ctr:0` | Búsqueda de todos los que viven actualmente en Cavabianca |
| dep | `ctr:1` | Búsqueda de todos los que viven actualmente en ctr dependientes (no en Cavabianca) |
| fuera, se han ido | `ctr:3` | Búsqueda de todos los que se han ido de Roma |
| no han llegado | `ctr:2` | Búsqueda de todos los que no se han incorporado todavía |


## Concatenación de Búsquedas

Si se especifican dos o más criterios, **PULPO** concatena por *default* las búsquedas con un operador `or`. Por ejemplo `group:2 year:1` buscará todos las personas que están en el grupo 2 o en el año 1. 

Si se quiere utilizar el operador `and` se debe especificar de forma explícita, i.e. `group:2 AND year:1`. Se puede escribir el operandor en mayúsculas o minúsculas: `group:2 AND year:1` o `group:2 and year:1` son búsquedas equivalentes.