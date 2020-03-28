Black Swan
==========

A project designed to provide personal data ownership and display.

See an example at https://brandur-org-black-swan.herokuapp.com.

## Deploy

Local:

```
brew install direnv
bundle install
createdb black-swan-development
bundle exec sequel -m db/migrate postgres://localhost/black-swan-development
cp .envrc.sample .envrc
direnv allow
bin/spider
bundle exec puma --quiet --threads 8:32 --port 5000 config.ru

# navigate to localhost:5000
```

Platform:

```
heroku create
git push heroku master
heroku run sequel -m db/migrate \$DATABASE_URL
heroku config:add FORCE_SSL=true
heroku config:add GOODREADS_ID=1234 GOODREADS_KEY=abcd
heroku config:add TWITTER_HANDLE=brandur TWITTER_ACCESS_TOKEN=abcd
heroku run bin/spider
heroku open
```

And furthermore if you'd like to automate event updates:

```
heroku addons:add scheduler:standard
heroku addons:open scheduler:standard
# use the web UI to add a job for `bin/spider`
```
