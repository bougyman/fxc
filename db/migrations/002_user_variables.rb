# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:user_variables) do
      primary_key :id
      String :name
      String :value
      foreign_key :user_id, :users, :null => false, :on_delete => :cascade
    end unless tables.include? :user_variables
  end

  def down
    remove_table(:user_variables) if tables.include? :user_variables #DB.tables.include? :user_variables
  end
end
