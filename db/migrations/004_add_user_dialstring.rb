# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:users) do
      add_column :dialstring, String, :default => '{presence_id=${dialed_user}@$${domain}}${sofia_contact(default/${dialed_user}@$${domain})}'
    end unless FXC.db[:users].columns.include? :dialstring
  end

  def down
    alter_table(:users) do
      drop_column :dialstring
    end if FXC.db[:users].columns.include? :dialstring
  end
end
