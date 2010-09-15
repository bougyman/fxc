# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require FXC::ROOT/:spec/:directory_data

describe 'FXC::Provider' do
  User, Target, Provider = FXC::User, FXC::Target, FXC::Provider

  it 'Should format a 10 digit number into a valid sofia url' do
    provider = Provider.new(:host => 'sip.vtwhite.com', :prefix => 1, :name => "VTWhite")
    provider.format("8179395222").should.equal "sofia/external/18179395222@sip.vtwhite.com"
  end

  it 'Should not format a non 10 digit number' do
    provider = Provider.new(:host => 'sip.vtwhite.com', :prefix => 1, :name => "VTWhite")
    provider.format("${sofia_contact(default/2600@$${domain})}").should.equal "${sofia_contact(default/2600@$${domain})}"
  end

end
