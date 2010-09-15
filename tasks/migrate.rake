# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software

desc "migrate to latest version of db"
task :migrate, :version do |_, args|
  args.with_defaults(:version => nil)
  require File.expand_path("../../lib/fxc", __FILE__)
  require Fxc::LIBPATH + "/fxc/db"
  require 'sequel/extensions/migration'

  raise "No DB found" unless Fxc.db

  require Fxc::PATH + "/model/init"

  if args.version.nil?
    Sequel::Migrator.apply(Fxc.db, Fxc::MIGRATION_ROOT)
  else
    Sequel::Migrator.run(Fxc.db, Fxc::MIGRATION_ROOT, :target => args.version.to_i)
  end

end
