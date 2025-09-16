# Pulpo

## Repositories

El código de Pulpo está en un hub local en los servidores de Cavabianca. La dirección es: http://gerbil.cavabianca.org/gitlab/abs/rpulpo. El branch se llama `master`

Para bajar el código a tu maquina local por primera vez:

```shell
git clone http://gerbil.cavabianca.org/gitlab/abs/rpulpo
```

Esto creará un direcotorio llamado rpulpo dentro del directorio acutal en el que estabas.

Una vez que hayas hecho los cambios necesarios, corregir errores, etc, se pude subir el código a `gerbil`.

Antes de hacerlo te recomiendo que veas qué remote reps están definidos. Si ejecutas

```shell
git remote -v
```

verás los repositorios definidos. Probablemente verás algo así como

```shell
origin	http://gerbil.cavabianca.org/gitlab/abs/rpulpo (fetch)
origin	http://gerbil.cavabianca.org/gitlab/abs/rpulpo (push)
```

Esto quiere decir que tu repositorio remoto se llama origin y su dirección es `http://gerbil.cavabianca.org/gitlab/abs/rpulpo`

```shell
git add .
git commit -m "mejoras increibles"
git push origin
```

Si todo va bien tu código ya está en gerbil. Lo ideal sería acceder a la direacción para comprobar que efectivamente los cambios se ha acturalizado. Ahora lo que tenemos que hacer es bajarlos a `minerva` que es la máquina virtual en la que corre pulpo.


Conectarsr via ssh a Minerva e ir al directorio rpulpo. El password de `administrador@minerva.cavabianca.org` es `29giu48$` 

```shell
ssh administrador@minerva.cavabianca.org
cd rpulpo
```

Si ejecutas  

```shell
git remote -v
```

probablemente verás dos repositorios definidos. Uno es el de `gerbil`. El otro es el repositorio enn `github` de Alejandro Bertelsen que es quien programó pulpo. 

```shell
origin	git@github.com:abertelsens/rpulpo.git (fetch)
origin	git@github.com:abertelsens/rpulpo.git (push)
upstream	http://gerbil.cavabianca.org/gitlab/abs/rpulpo (fetch)
upstream	http://gerbil.cavabianca.org/gitlab/abs/rpulpo (push)
```

Si quiere que él arregle algo, puedes contactralo (alejanddrobertelsen@gmail.com) y subir el código a su repositorio para que lo pueda ver. Tendrás que hacer


```shell
git push origin master
```

o el nombre que tenga el repositorio remoto. Por eso vale la pena revisarlo antes.

## Running pulpo

Pare correr o matar el proceso de pulpo hay un script que está en el directorio rpulpo. Bastaría escribir por ejemplo. Si no estuvieran en el $PATH por alguna razón habría que escribir `./pulpo stop` por ejemplo.

```shell
pulpo stop
pulpo start
```

## Base de Datos

La base de datos de pulpo está en postgress y se llama `rpulpo_db`. Para acceder a ella se puede escribir

```shell
psql rpulpo_db
```

Esto da acceso a la base. Hay que tener cuidado, pero si sabes lo que estás haciendo se puede manipular la base de datos directamente. No suele hacer falta.

Una cosa que sí puede ser interesante es hacer un backup de la base de datos. 


### Local Backup
To create a **backup of the local db** run
```
pg_dump -Fc --no-acl --no-owner rpulpo_db > rpulpo_db.dump
```
This will create a file called `rpulpo_db.dump`. This can be useful either as a backup or also to copy the db file to another machine to have real data to test the app.

To restore the local DB from a backup run:
```
psql template1 -c 'drop database rpulpo_db'
psql template1 -c 'create database rpulpo_db with owner administrador';
pg_restore -d rpulpo_db rpulpo_db.dump -U administrador
```

where ```rpulpo_db.dump``` is the backup file

