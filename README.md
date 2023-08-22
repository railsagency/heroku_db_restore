# Heroku DB Restore

A (for now) very opinionated gem makes it super easy to take a backup of a Heroku Postgres database, download it, and restore it.

This gem looks for two Environment Variables, each representing an app in either `staging` or `production` environments.

  1.  HEROKU_APPNAME_PRODUCTION=my-heroku-app
  2.  HEROKU_APPNAME_STAGING=my-heroku-app-staging

Set these in your `.env` file, or however you manage environment variables in your app.  We recommend `dotenv-rails`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'heroku_db_restore', group: :development # No need to include this on production or staging
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroku_db_restore

## Usage
To see an updated list of tasks and descriptions:
`bin/rake -T | grep db:restore`

~~~bash
rake db:restore                  # Pull Down a copy of the database from the specified heroku environment
rake db:restore:from_local_dump  # Restore from local dump file (defaults to '/tmp/latest.dump' - specify with DUMP_FILE Environmental Variable)
rake db:restore:local            # Erase local development and test database and restore from the local dump file
rake db:restore:production       # Restore a local copy of Heroku's Production Environment database
rake db:restore:staging          # Restore a local copy of Heroku's Staging Environment database
~~~


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/railsagency/heroku_db_restore.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
