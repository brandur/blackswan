README
======

A project designed to provide personal data ownership and display.

See an example at https://brandur-org-black-swan.herokuapp.com.

## Deploy

Local:

```
createdb black-swan-development
sequel -m db/migrate postgres://localhost/black-swan-development
bin/spider
foreman start
# navigate to localhost:5000
```

Platform:

```
heroku create
git push heroku master
heroku run sequel -m db/migrate \$DATABASE_URL
heroku config:add FORCE_SSL=true TWITTER_HANDLE=brandur
heroku run bin/spider
heroku open
```

And furthermore if you'd like to automate event updates:

```
heroku addons:add scheduler:standard
heroku addons:open scheduler:standard
# use the web UI to add a job for `bin/spider`
```
