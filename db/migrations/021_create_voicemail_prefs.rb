# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:voicemail_prefs) do
      String :username
      String :domain
      String :name_path
      String :greeting_path
      String :password

    end unless FXC.db.tables.include? :voicemail_prefs
  end

  def down
    remove_table(:voicemail_prefs) if FXC.db.tables.include? :voicemail_prefs
  end
end
