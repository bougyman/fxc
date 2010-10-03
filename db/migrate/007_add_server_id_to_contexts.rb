# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:dialplan_contexts) do
      add_foreign_key :server_id, :servers, :on_delete => :cascade
    end unless FXC.db[:dialplan_contexts].columns.include? :server_id

  end

  def down
    alter_table(:dialplan_contexts) do
      drop_column :server_id
    end if FXC.db[:dialplan_contexts].columns.include? :server_id
  end
end
