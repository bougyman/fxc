# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:dids) do
      primary_key :id
      String :number, :null => false
      TrueClass :primary, :default => false
      String :description
      String :clid_name
      foreign_key :user_id, :references => :users
    end unless FXC.db.tables.include? :dids
  end

  def down
    remove_table(:dids) if FXC.db.tables.include? :dids
  end
end
