# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:fs_conditions) do
      primary_key :id
      String :name
      String :description
      String :matcher
      String :expression
      Integer :position
      String :break
      foreign_key :extension_id, :fs_extensions, :on_delete => :cascade, :on_update => :cascade
    end unless FXC.db.tables.include? :fs_conditions
    execute "COMMENT ON TABLE fs_conditions IS 'Storage for Dialplan conditions'"
    execute "COMMENT ON COLUMN fs_conditions.name IS 'The name of this condition'"
    execute "COMMENT ON COLUMN fs_conditions.description IS 'Description of this condition'"
    execute "COMMENT ON COLUMN fs_conditions.matcher IS 'Which Field to match on'"
    execute "COMMENT ON COLUMN fs_conditions.expression IS 'The expression to match with'"
    execute "COMMENT ON COLUMN fs_conditions.position IS 'The order to match in'"
    execute "COMMENT ON COLUMN fs_conditions.break IS 'Whether to stop after this condition is met (or not)'"
    execute "COMMENT ON COLUMN fs_conditions.extension_id IS 'The associated extension record'"
  end

  def down
    drop_table(:fs_conditions) if FXC.db.tables.include? :fs_conditions
  end
end
