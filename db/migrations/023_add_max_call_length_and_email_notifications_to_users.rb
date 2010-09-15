# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:users) do
      add_column :email_notifications, TrueClass, :default => false
    end unless FXC.db[:users].columns.include? :email_notifications
    alter_table(:users) do
      add_column :max_call_length, Integer
    end unless FXC.db[:users].columns.include? :max_call_length
  end

  def down
    alter_table(:users) do
      drop_column :email_notifications
    end if FXC.db[:users].columns.include? :email_notifications
    alter_table(:users) do
      drop_column :max_call_length
    end if FXC.db[:users].columns.include? :max_call_length
  end
end
