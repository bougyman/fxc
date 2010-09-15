# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:users) do
      primary_key :id
      String :username, :null => false
      String :cidr, :default => "0.0.0.0/0"
      String :mailbox
      String :password
      String "vm-password"
    end unless FXC.db.tables.include? :users
  end

  def down
    remove_table(:users) if FXC.db.tables.include? :users
  end
end
