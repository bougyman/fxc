# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table :users do
      add_index :extension, :unique => true
      add_index :username, :unique => true
    end
  end

  def down
    alter_table :users do
      drop_index :extension
      drop_index :username
    end
  end
end
