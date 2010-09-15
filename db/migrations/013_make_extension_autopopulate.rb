# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table :users do
      rename_column :extension, :old_ext
      add_column :extension, :serial, :unique => true
      drop_constraint :extension_is_digits
      drop_index :extension
    end
    execute "UPDATE users set extension = old_ext::text::integer"
    execute "SELECT setval('users_extension_seq', 3175)"
    alter_table :users do
      drop_column :old_ext
    end
  end

  def down
    alter_table :users do
      rename_column :extension, :old_ext
      add_column :extension, String, :null => false
    end
    execute "UPDATE users set extension = old_ext"
    alter_table :users do
      drop_column :old_ext
      add_index :extension, :unique => true
    end
  end
end
