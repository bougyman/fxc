# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require FXC::ROOT/:spec/:directory_data

describe 'Did' do
  User, Did = FXC::User, FXC::Did

  it 'should have a DID' do
    did = Did[:number => "1901"]
    did.description.should == "Inbound DID Test"
  end

  it 'should have a relationship to a user' do
    did = Did[:number => "1901"]
    user = did.user
    user.class.should == FXC::User
  end
  
  it "should use a user's default dialstring if it has no targets" do
    did = Did[:number => "1901"]
    did.dialstring.should == "{presence_id=${dialed_user}@$${domain}}${sofia_contact(default/${dialed_user}@$${domain})}"
  end

  it "should change dialstring if it has a target" do
    did = Did[:number => "1901"]
    did.add_target(FXC::Target.new(:value => "sofia/default/8675309@127.0.0.1"))
    did.dialstring.should == "sofia/default/8675309@127.0.0.1"
  end

  it 'should set the did context to public upon creation' do
    did = Did.new(:number => "1112223311")
    did.context.should.be.nil
    did.save.reload.context.should.not.be.nil
    did.context.name.should.equal "public"
  end

end
