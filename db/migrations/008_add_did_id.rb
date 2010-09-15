# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:targets) do
      add_foreign_key :did_id, :dids, :on_delete => :cascade
    end unless FXC.db[:targets].columns.include? :did_id
  end

  def down
    [:did_id].each do |col|
      alter_table(:targets) do
        drop_column col
      end if FXC.db[:targets].columns.include? col
    end
  end
end
