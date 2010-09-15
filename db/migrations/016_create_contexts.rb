# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:dialplan_contexts) do
      primary_key :id
      String :name, :size => 40
      String :description
    end unless tables.include? :dialplan_contexts
    execute "COMMENT ON TABLE dialplan_contexts IS 'Storage for Dialplan Contexts'"
  end

  def down
    remove_table(:dialplan_contexts) if tables.include? :dialplan_contexts
  end
end
