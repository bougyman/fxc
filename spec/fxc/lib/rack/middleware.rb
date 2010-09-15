# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require_relative "../../../db_helper"
require "rubygems"
require "rack/test"

describe "Dialplan Routing" do
  User, Did, Target = FXC::User, FXC::Did, FXC::Target
  behaves_like :rack_test

  it "routes a dialplan request to /dialplan/context/" do
    user = User.find_or_create(:username => "potato")
    did = user.add_did(Did.new(:number => '2345678900'))
    did = user.add_target(Target.new(:value => '9994441234'))
    post "/", "section" => "dialplan", "Caller-Context" => 'public', "Caller-Destination-Number" => '12345678900'
    last_request.env["PATH_INFO"].should == %q{/dialplan/public/12345678900}
    last_response.body.should.include %q{expression="^1?(2345678900)$"}
  end
end

describe "Directory Routing" do
  User, Did, Target = FXC::User, FXC::Did, FXC::Target
  behaves_like :rack_test

  it "routes a register request to /directory/register/PROFILE/EXTENSION" do
    user = User.find_or_create(:username => "pacman", :extension => 2122, :active => true)
    post "/", "section" => "directory", "action" => 'sip_auth', "sip_profile" => 'internal', "sip_auth_username" => "2122"
    last_request.env["PATH_INFO"].should.equal %q{/directory/register/internal/2122}
    last_response.body.should.include %q{<user id="2122"}
  end

  it "sends not found to /directory/register/PROFILE/EXTENSION if user is inactive" do
    user = User.find_or_create(:username => "unpacman", :extension => 3122, :active => false)
    post "/", "section" => "directory", "action" => 'sip_auth', "sip_profile" => 'internal', "sip_auth_username" => "3122"
    last_request.env["PATH_INFO"].should.equal %q{/directory/register/internal/3122}
    last_response.body.should.include %q{status="not found"}
  end

  it "routes a voicemail request to /directory/voicemail/PROFILE/EXTENSION" do
    user = User.find_or_create(:username => "pacman", :extension => 2122)
    post "/", "section" => "directory", "Event-Calling-Function" => "voicemail_check", "user" => '2122', 'sip_profile' => 'special'
    last_request.env["PATH_INFO"].should.equal %q{/directory/voicemail/special/2122}
    last_response.body.should.include %q{<user id="2122"}
  end

  it "routes a message-count request to /directory/messages/EXTENSION/DOMAIN" do
    user = User.find_or_create(:username => "pacman", :extension => 2122)
    post "/", "section" => "directory", "user" => '2122', 'action' => 'message-count', "tag_name" => "domain", "key_value" => "foo.example.com"
    last_request.env["PATH_INFO"].should.equal %q{/directory/messages/2122/foo.example.com}
    last_response.body.should.include 'mailbox="2122"'
  end

  it "routes a user_data request to /directory/user_data/EXTENSION/DOMAIN" do
    user = User.find_or_create(:username => "pacman", :extension => 2122)
    post "/", "section" => "directory", "user" => '2122', "Event-Calling-Function"=>"user_data_function", "domain" => "foo.example.com"
    last_request.env["PATH_INFO"].should.equal %q{/directory/user_data/2122/foo.example.com}
    last_response.body.should.include 'mailbox="2122"'
  end

  it "routes a user_outgoing_channel request to /directory/user_outgoing/EXTENSION/DOMAIN" do
    user = User.find_or_create(:username => "pacman", :extension => 2122)
    post "/", "section" => "directory", "user" => '2122', "Event-Calling-Function"=>"user_outgoing_channel", "domain" => "foo.example.com"
    last_request.env["PATH_INFO"].should.equal %q{/directory/user_outgoing/2122/foo.example.com}
    last_response.body.should.include 'mailbox="2122"'
  end

  it "routes a network-list request to /directory/network_list/PROFILE" do
    user = User.find_or_create(:username => "pacman", :extension => 2122)
    user.update(:active => true)
    post "/", "section" => "directory", "purpose" => 'network-list', 'sip_profile' => 'special'
    last_request.env["PATH_INFO"].should.match %r{/directory/network_list/special}
    last_response.body.should.include %q{<user id="2122"}
  end
end
