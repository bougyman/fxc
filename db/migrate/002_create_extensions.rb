# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:fs_extensions) do
      primary_key :id
      String :name
      String :description
      TrueClass :continue
      Integer :position
      foreign_key :context_id, :dialplan_contexts, :on_update => :cascade
    end unless FXC.db.tables.include? :fs_extensions
    execute "COMMENT ON TABLE fs_extensions IS 'Storage for Freeswitch Extensions'"
    execute "COMMENT ON COLUMN fs_extensions.name IS 'The name of this extension'"
    execute "COMMENT ON COLUMN fs_extensions.description IS 'Description of this extension'"
    execute "COMMENT ON COLUMN fs_extensions.continue IS 'Whether to continue after running commands in this extension'"
    execute "COMMENT ON COLUMN fs_extensions.context_id IS 'The the reference to context this extension responds to'"
  end

  def down
    drop_table(:fs_extensions) if FXC.db.tables.include? :fs_extensions
  end
end
