# Copyright (c) 2008-2010 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software

require_relative '../../spec/helper'

describe 'configuration' do
  behaves_like :rack_test

  def req(key_value

  DEFOPTS = {"section" => "configuration", "key_name" => "name", "key_value" => nil, 'hostname' => TODO}
  it 'responds with not-found template' do
    get '/', DEFOPTS
    last_response.status.should == 200
    last_response['Content-Type'].should == 'freeswitch/xml'
    last_response.body.strip.should.not == ''

    doc = Nokogiri::XML(last_response.body)
    doc.at('document/section/result')[:status].should == 'not found'
  end

  it 'responds with a purpose=network-list' do
    post '/', DEFOPTS.merge(:purpose => 'network-list')
    last_response.status.should == 200
    last_response['Content-Type'].should == 'freeswitch/xml'
    last_response.body.strip.should.not == ''

    doc = Nokogiri::XML(last_response.body)
    doc.root.name.should == 'include'

    users = (doc/:user)
    users.size.should > 0

    # just some rough stuff
    user = users.first

    user[:mailbox].should.not.be.nil
    user[:id].should.not.be.nil
    user[:cidr].should.not.be.nil

    user.at("params/param[@name='password']").should.not.be.nil
    user.at("params/param[@name='dial-string']").should.not.be.nil
  end

  it 'responds to action=sip_auth' do
    post '/', DEFOPTS.merge(:action => 'sip_auth', :sip_auth_username => '1902')
    last_response.status.should == 200
    last_response.body.strip.should.not == ''

    doc = Nokogiri::XML(last_response.body)
    doc.root.name.should == 'include'

    # just some rough stuff
    user = doc.at :user

    user[:mailbox].should == '1902'
    user[:id].should == '1902'
    user[:cidr].should == '0.0.0.0/0'

    user.at("params/param[@name='password']")[:value].should =~ /^\d{4}$/
    user.at("params/param[@name='dial-string']").should.not.be.nil
  end

  it 'responds to user=1902 for voicemail' do
    post '/', section: "directory", user: 1902, "Event-Calling-Function" => "voicemail_leave_main"
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)
    doc.root.name.should == 'include'
    user = doc.at :user

    user[:mailbox].should == '1902'
    user[:id].should == '1902'
    user[:cidr].should == '0.0.0.0/0'

    user.at("params/param[@name='password']")[:value].should =~ /^\d{4}$/
    user.at("params/param[@name='dial-string']").should.not.be.nil
  end

  it 'sets nibble_rate and nibble_account when user has a nibble_rate' do
    post '/', section: "directory", user: 1902
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)
  end
end
