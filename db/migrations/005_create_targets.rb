# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:targets) do
      primary_key :id
      String :value, :null => false
      String :type, :default => "landline", :null => false
      Integer :priority, :default => 1, :null => false
      foreign_key :user_id, :users, :on_delete => :cascade
    end unless tables.include? :targets
  end

  def down
    remove_table(:targets) if tables.include? :targets
  end
end
