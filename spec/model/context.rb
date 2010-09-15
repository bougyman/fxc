# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require FXC::ROOT/:spec/:directory_data

describe 'FXC::Context' do
  User, Target, Context, Did = FXC::User, FXC::Target, FXC::Context, FXC::Did

  it 'should always have a default context' do
    default = Context.default
    default.should.not.be.nil?
    default.name.should.equal "default"
  end

  it 'should always have a public context' do
    pub = Context.public
    pub.should.not.be.nil?
    pub.name.should.equal "public"
  end

  it "should list users in the context" do
    user = User.find_or_create(:username => "msfoo")
    Context.default.add_user(user).should.not.be.nil
    Context.default.users.map { |u| u.username }.should.include "msfoo"
  end

  it "should list DIDs in the context" do
    did = Did.find_or_create(:number => "8675309")
    Context.public.add_did(did).should.not.be.nil
    Context.public.dids.map { |n| n.number }.should.include "8675309"
  end

end
