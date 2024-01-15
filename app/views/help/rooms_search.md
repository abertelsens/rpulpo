# Búsqueda de Habitaciones

El campo de búsqueda funciona de modo similar a otras aplicaciones. Para buscar por el nombre de la habitació basta teclear en el campo el texto que se quiera buscar. Por ejemplo `corazones` buscará todas las habitaciones con **nombre** que contenga "corazones". Las máyusculas son ignoradas: `Corazones` o `CORAZONES` arrojan el mismo resultado.

Si se quiere buscar por **otros campos** estos se deben especificar. Por ejemplo `house:1` buscará todas las personas que pertenecen a la zona de dirección . No hace falta escribir espacios después de los dos puntos, pero tampoco pasa nada si se hace. El nombre del campo debe estar bien escrito, si no el programa no es capaz de entender lo que se quiere, por ejemplo `hous:1` no dará ningún resultado porque no existe un campo llamado `hous`.

Hay algunos **campo de tipo numérico**, por ejemplo `house`. Ver tablas *query aliases* más abajo para todas las posibilidades.

## Lista de campos y posibilidades para nombrarlos:

| Campo | Type | Descripción | Aliases |
| ---- | ---- | ---- | ---- |
| room | string |  | nombre de la habitación | habitación, habitacion, hab |
| house | integer |  | zona de la casa | casa, zona | 
| floor | string | planta de la habitación: baja, 1, 2 | planta, piso |
| bed | integer | tipo de cama de la habitación | cama |
| matress | string | tipo de colchón | colchón, colchon  |
| bathroom | integer | tipo de baño | bath, baño |
| phone | integer | teléfono interno más cercano | tel, telefono, teléfono |


## Query Aliases

Se ofrecen algunos aliases para búsqueda más frecuentes. 

| Alias(es) | Query | Descripción |
| ---- | ---- | ---- |
| dirección, direccion, dir | `house:0` | Habitaciones de la zona de dirección |
| profesores, prof | `house:1` | Habitaciones de la zona de profesores |
| pabellón, pabellon | `house:2` | Habitaciones de la zona del pabellón |
| conferencias | `house:3` | Habitaciones de la zona de sala de conferencias |
| altana | `house:4` | Habitaciones de la casa de la Altana |
| chiciciolla, chio  | `house:5` | Habitaciones de la casa de la Chicciolla |
| molino, mulino  | `house:6` | Habitaciones de la casa del Molino |
| borgo  | `house:7` | Habitaciones de la casa de la Casa del Borgo |
| ospiti  | `house:8` | Habitaciones de la casa de Ospiti |
| enfermería, enfermeria | `house:9` | Habitaciones de la zona de Enfermería |
| consejo, cg | `house:10` | Habitaciones de la Casa del Consejo |
| normal | `bed:0` | Habitaciones con cama normal |
| larga | `bed:1` | Habitaciones con cama larga |
| reclinable | `bed:2` | Habitaciones con cama reclinable |
| individual | `bathroom:0` | Habitaciones con baño individual |
| común, común | `bathroom:1` | Habitaciones con baño común |

## Concatenación de Búsquedas

Si se especifican dos o más criterios, **PULPO** concatena por *default* las búsquedas con un operador `or`. Por ejemplo `profesores borgo` buscará todos las habitaciones de profesores o del borgo. 

Si se quiere utilizar el operador `and` se debe especificar de forma explícita, i.e. `individual AND borgo` dará todas las habitaciones con baño individual en casa del Borgo.