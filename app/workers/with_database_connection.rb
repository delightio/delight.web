module WithDatabaseConnection
  def after_fork_connect_to_database *args
    ActiveRecord::Base.establish_connection database_url
  end

  def after_perform_disconnect_db *args
    ActiveRecord::Base.connection.disconnect!
  end

  def database_url
    return ENV['DATABASE_URL'] if ENV['DATABASE_URL']

    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    port     = config[Rails.env]["port"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    "postgres://#{username}:#{password}@#{host}:#{port}/#{database}"
  end
end
