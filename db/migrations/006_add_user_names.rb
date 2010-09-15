# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    [:first_name, :last_name].each do |col|
      alter_table(:users) do
        add_column col, String
      end unless FXC.db[:users].columns.include? col
    end
  end

  def down
    [:first_name, :last_name].each do |col|
      alter_table(:users) do
        drop_column col
      end if FXC.db[:users].columns.include? col
    end
  end
end
