# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#

class FXC::Did < Sequel::Model(FXC.db[:dids])
  many_to_one :user, :class => 'FXC::User', :one_to_one => true
  one_to_many :targets, :class => 'FXC::Target'
  many_to_one :context, :class => 'FXC::Context'

  @scaffold_human_name = 'DID'
  @scaffold_column_types = {
    :number => :integer,
    :description => :string,
    :clid_name => :string,
  }

  def scaffold_name
    "#{clid_name} (#{number})"
  end

  def dialstring
    FXC::Dialstring.new(user, targets, user.dialstring).to_s
  end

  def after_create
    FXC::Context.public.add_did(self) if context.nil?
  end

  def blocked?(number, name = nil)
    false
  end

  def accept?(number, name = nil)
    true
  end
end
