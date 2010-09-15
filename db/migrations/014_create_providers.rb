# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:providers) do
      primary_key :id
      String :format, :null => false
      Integer :priority, :null => false, :default => 0, :unique => true
      String :description
      String :name, :size => 30
      String :host, :size => 40
      Integer :port, :default => 5060
      String :prefix, :size => 1
    end unless tables.include? :providers
    execute "COMMENT ON TABLE providers IS 'Storage for VOIP Service Providers that we allow'"
    execute "COMMENT ON COLUMN providers.format IS 'The printf format string for this provider, used in dialstrings'"
    execute "COMMENT ON COLUMN providers.priority IS 'The (unique) priority for this provider, lower priorities get dialed first'"
    execute "COMMENT ON COLUMN providers.prefix IS 'The number to dial before a 10 digit (US and CANADA) outbound number'"
  end

  def down
    remove_table(:providers) if tables.include? :providers
  end
end
