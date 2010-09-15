# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
class FXC::Target < Sequel::Model(FXC.db[:targets])
  many_to_one :user, :class => 'FXC::User'
  many_to_one :did, :class => 'FXC::Did'

  @scaffold_human_name = 'Target'
  @scaffold_column_types = {
    :type => :string,
    :value => :string,
  }

  def dialstring
    value
  end
end
