namespace :db do
  desc 'Pull Down a copy of the database from the specified heroku environment'
  task :restore do
    env = ENV['ENV']

    abort "Please specify ENV=production or ENV=staging" unless env
    app = app_name_from_environment(env)

    if ENV['LATEST'] #if this is here, then create a fresh backup, if not grab whichever is the latest
      sh "heroku pg:backups:capture --app #{app}"
    end

    sh "heroku pg:backups:download --output=tmp/latest.dump --app #{app}"

    #ensures there are no extra tables or views
    Rake::Task["db:restore:local"].invoke
  end

  namespace :restore do
    desc "Restore a local copy of Heroku's Staging Environment database"
    task :staging do
      ENV['ENV'] = "staging"
      Rake::Task["db:restore"].invoke
    end

    desc "Restore a local copy of Heroku's Production Environment database"
    task :production do
      ENV['ENV'] = "production"
      Rake::Task["db:restore"].invoke
    end

    desc "Erase local development and test database and restore from the local dump file."
    task :local do
      ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
      #ensures there are no extra tables or views
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke

      Rake::Task["db:restore:from_local_dump"].invoke
      #migrate the database, remove sensitive information, and setup tests
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:test:prepare"].invoke
    end

    desc "Restore from local dump file (defaults to '/tmp/latest.dump' - specify with DUMP_FILE Environmental Variable)"
    task :from_local_dump do
      dump_file_location = (ENV['DUMP_FILE'] || "tmp/latest.dump")
      #in backticks so that pg_restore warnings dont exit this routine
      `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 PGPASSWORD="#{local_database_password}" pg_restore --verbose --clean --no-acl --no-owner -h #{local_database_host} -d #{local_database_name} -p #{local_database_port} -U #{local_database_user} #{dump_file_location}`
    end
  end
end

def local_database_host
  Rails.configuration.database_configuration[Rails.env]["host"]
end

def local_database_name
  Rails.configuration.database_configuration[Rails.env]["database"]
end

def local_database_port
  Rails.configuration.database_configuration[Rails.env]["port"]
end

def local_database_user
  Rails.configuration.database_configuration[Rails.env]["username"]
end

def local_database_password
  Rails.configuration.database_configuration[Rails.env]["password"]
end

def app_name_from_environment(env)
  case env.downcase
  when "production"
    ENV['HEROKU_APPNAME_PRODUCTION'] || "#{Rails.application.class.parent_name.underscore.gsub('_','-')}"
  when "staging"
    ENV['HEROKU_APPNAME_STAGING'] || "#{Rails.application.class.parent_name.underscore.gsub('_','-')}-staging"
  end
end
