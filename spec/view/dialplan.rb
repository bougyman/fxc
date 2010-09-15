# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require FXC::ROOT/:spec/:directory_data

describe 'dialplan' do
  behaves_like :rack_test

  DEFOPTS = {"section" => "dialplan"}
  it 'responds with not-found template' do
    post '/', DEFOPTS
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)

    doc.root.name.should == 'document'
    sections = (doc/:section)
    sections.size == 1
    sections.first.at(:result)[:status].should == 'not found'
  end

  it 'responds with not-found template when searching for an extension' do
    post '/', DEFOPTS.merge("Caller-Context" => "default", "Caller-Destination-Number" => "12345")
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)

    doc.root.name.should == 'document'
    sections = (doc/:section)
    sections.size == 1
    sections.first.at(:result)[:status].should == 'not found'
  end


  it 'responds to a public call and uses User.dialstring as the bridge data' do
    post '/', DEFOPTS.merge("Caller-Context" => "public", "Caller-Destination-Number" => "1901")
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)

    doc.root.name.should == 'include'
    extensions = (doc/:extension)
    (extension = extensions.first).should.not.be.nil
    extension[:name].should.equal "Inbound DID Test"
    conditions = (doc/:extension/:condition)
    (condition = conditions.first).should.not.be.nil
    condition[:field].should.equal "destination_number"
    condition[:expression].should.equal "^1?(1901)$"
    actions = (doc/:extension/:condition/:action)
    bridge_action = actions.last
    bridge_action[:application].should.equal "voicemail"
    bridge_action[:data].should.equal "default $${domain} 1901"
  end

  it 'responds to a public call and uses Target.value as the bridge data' do
    post '/', DEFOPTS.merge("Caller-Context" => "public", "Caller-Destination-Number" => "1902")
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)

    doc.root.name.should == 'include'
    extensions = (doc/:extension)
    (extension = extensions.first).should.not.be.nil
    extension[:name].should.equal "Inbound DID Test #2"
    conditions = (doc/:extension/:condition)
    (condition = conditions.first).should.not.be.nil
    condition[:field].should.equal "destination_number"
    condition[:expression].should.equal "^1?(1902)$"
    actions = (doc/:extension/:condition/"action")
    bridge_action = actions.detect { |ac| ac['application'] == 'bridge' }
    # Uses Target, not default User#dialstring
    bridge_action[:data].should.equal "${sofia_contact(default/1902@${dialed_domain})}"
  end

end

