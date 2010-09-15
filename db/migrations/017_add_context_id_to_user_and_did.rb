# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    execute "CREATE FUNCTION lookup_context (TEXT) RETURNS INTEGER AS 'SELECT id FROM dialplan_contexts WHERE name = $1' LANGUAGE SQL"
    alter_table(:users) do
      add_foreign_key :context_id, :dialplan_contexts, :on_delete => :cascade, :default => :lookup_context.sql_function('default')
    end unless FXC.db[:users].columns.include? :context_id

    alter_table(:dids) do
      add_foreign_key :context_id, :dialplan_contexts, :on_delete => :cascade, :default => :lookup_context.sql_function('public')
    end unless FXC.db[:dids].columns.include? :context_id
  end

  def down
    [:dids, :users].each do |table|
      alter_table(table) do
        drop_column :context_id
      end if FXC.db[table].columns.include? :context_id
    end
  end
end
