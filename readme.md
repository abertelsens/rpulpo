# Merge Resolution Complete

The merge conflicts have been resolved by:

1. In `app/routes/entities.rb`: Using `slim` for rendering the entity form, consistent with other form templates
2. In `app/routes/mails.rb`: 
   - Keeping the Pandoc reference comment
   - Using the nil coalescing operator pattern for the query assignment
   - Using `partial` for frame rendering
3. In `app/routes/people.rb`: Using `redirect "/people"` for consistency with other routes

To complete the merge process, run:

```
git add app/routes/entities.rb app/routes/mails.rb app/routes/people.rb
git commit -m "Resolve merge conflicts in route files"
```

This will finalize the merge and allow you to continue working with the repository.


bundle exec ruby .\app\main.rb -o 0.0.0.0 -p 2948 -e production
bundle exec puma -p 4567

http://localhost:4567/



bundle exec puma -C "./config/puma.rb"


git branch test

# DB Management

 bundle exec rake db:setup
 bundle exec rake db:migrate
 bundle exec rake db:drop
 
bundle exec rake db:create_migration NAME=requestpayments
bundle exec rake db:migrate:up VERSION=20240410141410
bundle exec rake db:migrate:down VERSION=20230227091407


 db:migrate runs (single) migrations that have not run yet.
 db:create creates the database
 db:drop deletes the database
 db:schema:load creates tables and columns within the existing database following schema.rb. This will delete existing data.
 db:setup does db:create, db:schema:load, db:seed
 db:reset does db:drop, db:setup
 db:migrate:reset does db:drop, db:create, db:migrate


## Local Postgres Database 
### General
```
db name: rpulpo_db
user name: alejandro
```

**Start Postgres server**
```
pg_ctl -D /usr/local/var/postgres start
```

**Stop the server**
```
pg_ctl -D /usr/local/var/postgres stop
```
Esto también ha funcionado
```
brew services list
brew services restart postgresql@14
```
**Create a Database**
```
createdb rpulpo_db
```

**Delete DB**
```
dropdb rpulpo_db
```
Open Postgress CLI utilities (CTRL + d to exit)
```
psql rpulpo_db
```


### Local Backup
To create a **backup of the local db** run
```
pg_dump -Fc --no-acl --no-owner -h localhost -U ale saxum_act_db > saxum_act_db.dump
```

To restore the local DB from a backup run:
```
psql template1 -c 'drop database rpulpo_db'
psql template1 -c 'create database saxum_act_db with owner alejandro';
pg_restore -d rpulpo_db rpulpo_db.dump -U alejandro
```
where ```saxum_act_db.dump``` is the backup file

## Heroku
[https://dashboard.heroku.com/apps/](https://dashboard.heroku.com/apps/)

```
uname: 	abs@saxum.org
pass: 	beTurco2000!
```	

### Uploading a DB backup to Heroku

After dumping the DB and creating a backup file. In order to upload it to hereku we need to move it somewhere heroku can have access. 

1. Upload it to **Dropbox Public Folder**
2. **Get the download link**. It is necessary to get the real accesible link (download the file and get it from the browser). It should look something like 
	
	```
	https://uc916a76095e0c8933a6a36f94f6.dl.dropboxusercontent.com/cd/0/get/BJ746Wo_wcVk54WCLWpuKdFpQagpP0pqH47gnh3q7HDX9wgkauvtZ75zM4K8fiJSuRRBCTtAWmd7l9X4BVvB7kcWV02dgrp8CLrAtcIKKlZ33DEbJD446IiBth5art-RgiU/file#
	```

3. **Upload to heroku** using:
	```
	heroku pg:backups:restore '$DROPBOX_PATH' DATABASE_URL --app saxumactivities
	```
* Heroku might prompt for a confirmation.

## Git Hub

```
github token: baacdb70d7a3b36ce1ea2c764f881aadfc1ccea7
```

Make sure we are in the right folder of the repository. It is called ```saxum_rep```

**update in git**
```
git add .
git commit -m "lots of changes"
```
**pushing to GitHub and to Heroku**
```
git push heroku main
git push origin main 
```


## Running Locally
Make sure you are in ```saxum_rep```
```
bundle exec ruby app/saxum_act.rb
```

## Other Resources
### Bundler
- Deploying: [https://bundler.io/v1.0/deploying.html](https://bundler.io/v1.0/deploying.html)
-[https://bundler.io/guides/using_bundler_in_applications.html](https://bundler.io/guides/using_bundler_in_applications.html)

### Datamapper
- [http://stensi.com/datamapper/pages/gettingstarted.html](http://stensi.com/datamapper/pages/gettingstarted.html)

### Sinatra

-  [Sinatra File Structure](https://medium.com/@orkunsalam/my-sinatra-project-21237f5c25d2)
- [Using sinatra with multiple files for large projects](http://www.itgo.me/a/1046081731997675638/using-sinatra-for-larger-projects-via-multiple-files)

### Deploying to Heroku
- [Deploying a sinatra-postgres app to heroku](https://medium.com/@dmccoy/deploying-a-simple-sinatra-app-with-postgres-to-heroku-c4a883d3f19e)

