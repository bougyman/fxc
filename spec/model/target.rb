# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require FXC::ROOT/:spec/:directory_data

describe 'Target' do
  User, Target = FXC::User, FXC::Target

  it 'Should change a users dialstring when we add a Target' do
    user = User[:extension => "1901"]
    user.dialstring.should == "{presence_id=${dialed_user}@$${domain}}${sofia_contact(default/${dialed_user}@$${domain})}"
    user.add_target(Target.new(:value => "user/1901"))
    user.dialstring.should == "user/1901"
  end

  it 'Should change a did dialstring when we add a Target' do
    user = User[:extension => "1901"]
    (did = user.dids.first).number.should.equal "1901"
    did.dialstring.should.equal user.dialstring
    did.add_target(Target.new(:value => "sofia/external/1234@sip.foo.com"))
    did.dialstring.should.equal "sofia/external/1234@sip.foo.com"
  end

end
