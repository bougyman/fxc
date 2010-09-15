# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)

describe 'FXC::User' do
  User, Target = FXC::User, FXC::Target
  @defaults = {:extension => 1234, :username => "fxc", :first_name => "tj", :last_name => "vanderpoel", :password => "a+b3t4r;pvs6"}
  @auto_create_min = 3176

  after do
    User.delete
  end

  it 'should auto-assign extension when none given' do
    u = User.create(:first_name => "tj")
    u.extension.should.equal @auto_create_min
  end

  it 'should hash password on assingment' do
    u = User.create(:username => "tj", :password => 'weak sauce')
    u.password.should.not.equal 'weak sauce'
    u.password.should.equal User.digestify('weak sauce')
  end

  it 'should not allow directly assigned extensions in the auto-populate range (<3176)' do
    lambda { User.create(:extension => 3177) }.should.raise(Sequel::ValidationFailed).
      message.should.match /extension can not be directly assigned above #{@auto_create_min-1}/
  end

  it 'should require extension to be 4+ digits' do
    lambda { User.create(:extension => "bougyman") }.should.raise(Sequel::InvalidValue)
    lambda { User.create(:extension => 123) }.should.raise(Sequel::ValidationFailed).
      message.should.match /must be all digits \(4 minimum\)/
  end

  it 'should require pin to be 4+ digits' do
    lambda { User.create(:extension => 1234, :pin => "foo") }.should.raise(Sequel::ValidationFailed).
      message.should.match /must be all digits \(4 minimum\)/
    lambda { User.create(:extension => 1234, :pin => 123) }.should.raise(Sequel::ValidationFailed).
      message.should.match /must be all digits \(4 minimum\)/
  end

  it 'should not allow duplicate extension' do
    user = User.create(:extension => 1234)
    lambda { User.create(:extension => 1234) }.should.raise(Sequel::ValidationFailed).
      message.should.match /extension can not be duplicated/
  end

  it 'should not allow duplicate username' do
    user = User.create(:extension => 1234, :username => 'crusty')
    lambda { User.create(:extension => 2234, :username => 'crusty') }.should.raise(Sequel::ValidationFailed).
      message.should.match /username can not be duplicated/
  end

  it 'should be inactive upon initial creation' do
    user = User.create(:extension => 1234)
    user.active.should.be.false
  end

  it 'should make mailbox equal to extension if it is not specified' do
    user = User.create(:extension => 1234)
    user.mailbox.should.equal user.extension.to_s
  end

  it 'should require mailbox be 4+ digits' do
    lambda { User.create(:extension => 1234, :mailbox => "foo") }.should.raise(Sequel::ValidationFailed).
      message.should.match /must be all digits \(4 minimum\)/
    lambda { User.create(:extension => 1234, :mailbox => 123) }.should.raise(Sequel::ValidationFailed).
      message.should.match /must be all digits \(4 minimum\)/
  end

  it 'should have a default dialstring when created' do
    user = User.create(@defaults)
    user.dialstring.should === "{presence_id=${dialed_user}@$${domain}}${sofia_contact(default/${dialed_user}@$${domain})}"
  end

  it 'should add default user_variables when created' do 
    user = User.create(@defaults)
    user.user_variables.size.should.equal 5
  end

  it 'should set the user context to default upon creation' do
    user = User.new(:extension => 1234)
    user.context.should.be.nil
    user.save.reload.context.should.not.be.nil
    user.context.name.should.equal "default"
  end

  it 'should allow multiple users (with usernames)' do 
    user = User.create(:extension => 1191, :username => 'pete')
    user2 = User.create(:extension => 1192, :username => "frodo")
    User.all.size.should.equal 2
  end

  it 'should allow multiple users (no usernames)' do 
    user = User.create(:extension => 1191)
    user2 = User.create(:extension => 1199)
    User.all.size.should.equal 2
  end
end
