# Búsqueda de Datos Internos del Colegio Romano

La tabla de Datos del crs+ contiene información sobre las admisiones así como los ministerios laicales y ordenaciones.
## Lista de campos y posibilidades para nombrarlos:

| Campo | Type | Descripción | Aliases |
| ---- | ---- | ---- | ---- |
| pa | date | Fecha de pitaje |  |
| admision | date | Fecha de la admisión |  |
| oblacion | date | Fecha de la oblación |  |
| fidelidad | date | Fecha de la fidelidad |  |
| letter | date | Fecha en la que entregó la carta manidestando sus deseos de ordenarse |  |
| lectorado | date | Fecha del lectorado |  |
| acolitado | date | Fecha del acolitado |  |
| diaconado | date | Fecha del diaconado |  |
| presbiterado | date | Fecha del presbiterado |  |
| cipna | string | año(s) en los que estuvo en Aralar |  |
| classnumber | string | promoción del Colegio Romano |  |
| phase | integer | Estapa de acuerdo a las etapas definidas por el Dicasterio del Clero | fase, etapa |


## Query Aliases

La tabla contiene más datos, pero la búsqueda se ha restringido a estos campos.

Se ofrecen algunos aliases para búsqueda más frecuentes. 

| Alias(es) | Query | Descripción |
| discipular, disc | `phase:0` | Búsqueda de todos los que están en la etapa discipular |
| configuracional, config | `phase:1` | Búsqueda de todos los que están en la etapa configuracional |
| sintesis, sintesis, sint | `pahse:2` | Búsqueda de todos los que están en la etapa de síntesis |