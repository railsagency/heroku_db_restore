class HerokuDbRestore::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/db_restore.rake'
    load 'tasks/db_restore.rake'
  end
end
