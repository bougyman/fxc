# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:users) do
      add_column :extension, String, :size => 10
    end unless FXC.db[:users].columns.include? :extension

    alter_table(:users) do
      add_column :pin, String, :size => 10
    end unless FXC.db[:users].columns.include? :pin

    execute "COMMENT ON COLUMN users.username IS E'The username a for logging in to the website'"
    execute "COMMENT ON COLUMN users.extension IS E'The user''s extension. must be numeric to log in via phone, accepting leading zeros forces String'"
    execute "COMMENT ON COLUMN users.pin IS E'The pin number used for authentication on phone applications (same rules as pin, \\d+)'"

    # For legacy dbs
    execute("UPDATE users SET extension = username WHERE extension IS NULL")
    execute("UPDATE users SET pin = \"vm-password\" WHERE pin IS NULL")
    execute("ALTER TABLE users ADD CONSTRAINT no_null_extensions CHECK (extension IS NOT NULL)")

    # Get rid of the columns we don't need
    alter_table(:users) do
      drop_column :"vm-password"
      drop_column :username
      add_column :username, String, :size => 40
    end
  end

  def down
    raise Sequel::Error, "You can't go down from here, buddy"
  end
end
