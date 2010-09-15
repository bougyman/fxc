# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
class FXC::UserVariable < Sequel::Model(FXC.db[:user_variables])
  many_to_one :user, :class => 'FXC::User'

  @scaffold_human_name = 'User Variable'
  @scaffold_column_types = {
    :name => :string,
    :value => :string,
  }

  def scaffold_name
    "#{name}: #{value}"
  end
end
