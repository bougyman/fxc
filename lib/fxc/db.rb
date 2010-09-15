# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# See the LICENSE file which accompanies this software for the full text
#
# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
begin
  require "sequel"
rescue LoadError
  require "rubygems"
  require "sequel"
end
require "logger"

module FXC
  unless defined?(@@db)
    @@db = nil
  end

  def self.db
    setup_db
  end

  def self.db=(other)
    @@db = other
  end

  private

  def self.parse_pgpass(file, database)
    dbs = {}

    defaults = {
      host: "localhost", port: 5432, db: database,
      user: ENV["USER"], password: nil
    }

    file.readlines.each do |line|
      chunks = line.strip.split(/:/)
      dbs[chunks[2]] = Hash[defaults.keys.zip(chunks)]
    end

    db =  dbs[database] || dbs['*']
    if db 
      chosen = db.reject{|k,v| !v || v == '*' }
      defaults.merge(chosen)
    else
      fail("Either #{database}, *, or db named in APP_DB not found in .pgpass")
    end
  end

  def self.setup_db(root = FXC::ROOT, default_app = 'fxc')
    return @@db if @@db

    app_db  = ENV["APP_DB"]  || default_app
    app_env = ENV["APP_ENV"] || "development"
    root_pgpass = root/".pgpass"
    home_pgpass = Pathname('~/.pgpass').expand_path

    if root_pgpass.file?
      conn = parse_pgpass(root_pgpass, app_db)
    elsif home_pgpass.file?
      conn = parse_pgpass(home_pgpass, app_db)
    else
      msg = "You have no %p or %p, can't determine connection"
      fail(msg % [root_pgpass.to_s, home_pgpass.to_s])
    end

    logfile = root/:log/"#{app_env}.log"
    logfile.parent.mkpath
    logger = ::Logger.new(logfile)

    if app_db.nil?
      logger.debug("setup_db called but no database defined")
      @@db = nil
    else
      logger.info("Connecting to #{app_db}")
      conn[:logger] = logger
      @@db = ::Sequel.postgres(app_db, conn)
    end
  end
end
