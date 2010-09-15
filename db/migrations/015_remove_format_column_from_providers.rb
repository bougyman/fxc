# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:providers) do
      drop_column :format
    end
  end

  def down
    alter_table(:targets) do
      add_column :format, String, :null => false
    end
  end
end
