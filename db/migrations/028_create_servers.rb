# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:servers) do
      primary_key :id
      String :name
      String :description
    end unless tables.include? :servers
    execute "COMMENT ON TABLE servers IS 'List of freeswitch servers'"
  end

  def down
    remove_table(:servers) if tables.include? :servers
  end
end
