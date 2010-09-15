# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
class FXC::Context < Sequel::Model(FXC.db[:dialplan_contexts])
  one_to_many :users, :class => 'FXC::User'
  one_to_many :dids, :class => 'FXC::Did'
  one_to_many :extensions, :class => 'FXC::Extension'
  one_to_many :gateways, :class => 'FXC::SipGateway', :key => :dialplan_context_id

  @scaffold_human_name = 'DID Context'
  @scaffold_column_types = {
    :description => :string
  }

  def self.default
    find_or_create(:name => "default")
  end

  def self.public
    find_or_create(:name => "public")
  end
end
