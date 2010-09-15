# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path("../../../db_helper", __FILE__)
require FXC::ROOT/:lib/:fxc/:dialstring
describe "Dialstring" do
  @user = FXC::User.create(:extension => "1909", :pin => "1234")
  it "should return the user's dialstring when there are no targets given, and no default" do
    dialstring = FXC::Dialstring.new(@user, [])
    dialstring.to_s.should.equal @user.values[:dialstring]
  end
  
  it "should return the dialstring passed as default when there are no targets given" do
    dialstring = FXC::Dialstring.new(@user, [], endpoint = "sofia/external/abc@example.com")
    dialstring.to_s.should.equal endpoint
  end

  it "should return a single target when it is passed and no default given" do
    target = FXC::Target.find_or_create(:value => "user/1909")
    target.priority.should.equal 1
    target.dialstring.should.equal "user/1909"
    dialstring = FXC::Dialstring.new(@user, [target])
    dialstring.to_s.should.equal target.dialstring
  end
  
  it "should return a single target with a dummy provider when none are in the db" do
    target = FXC::Target.find_or_create(:value => "8881112345")
    dialstring = FXC::Dialstring.new(@user, [target], "error/do-not-call")
    dialstring.provider.format(target.dialstring).should.equal "sofia/external/18881112345@sip.example.com"
    dialstring.to_s.should.equal dialstring.provider.format(target.dialstring)
  end

  it "should return a single target with a provider of priority 0 when it exists in the db" do
    begin
      provider = FXC::Provider.create(:host => "sip.unexample.net", :prefix => "7")
      target = FXC::Target.find_or_create(:value => "8881112345")
      dialstring = FXC::Dialstring.new(@user, [target], "error/do-not-call")
      dialstring.provider.format(target.dialstring).should.equal "sofia/external/78881112345@sip.unexample.net:5060"
      dialstring.to_s.should.equal dialstring.provider.format(target.dialstring)
    ensure
      provider.destroy
    end
  end

  it "should return a target for the given provider when a provider is passed" do
    target = FXC::Target.find_or_create(:value => "8881112345")
    dialstring = FXC::Dialstring.new(@user, [target], "error/do-not-call", FXC::Provider.new(:host => "sip.example2.com", :prefix => ""))
    dialstring.provider.format(target.dialstring).should.equal "sofia/external/8881112345@sip.example2.com"
    dialstring.to_s.should.equal dialstring.provider.format(target.dialstring)
  end

  # All subsequent specs will call #new with the default of error/do-not-call

  it "should return two targets to ring concurrently when they're the same priority" do
    target1 = FXC::Target.find_or_create(:value => "user/1909")
    target2 = FXC::Target.find_or_create(:value => "user/1910")
    dialstring = FXC::Dialstring.new(@user, [target1, target2], "error/do-not-call")
    dialstring.to_s.should.equal "user/1909,user/1910"
  end

  it "should return two targets to ring alternately when they're different priorities" do
    target1 = FXC::Target.find_or_create(:value => "user/1909")
    target2 = FXC::Target.find_or_create(:value => "user/1910", :priority => 2)
    target2.priority.should.equal 2
    dialstring = FXC::Dialstring.new(@user, [target1, target2], "error/do-not-call")
    dialstring.to_s.should.equal "user/1909|user/1910"
  end

  it "should return primary target, then two concurrent secondaries, and a fallback target" do
    target1 = FXC::Target.find_or_create(:value => "[call-timeout=10]user/1909")
    target2 = FXC::Target.find_or_create(:value => "user/1910", :priority => 2)
    target3 = FXC::Target.find_or_create(:value => "user/1911", :priority => 2)
    target4 = FXC::Target.find_or_create(:value => "user/1912", :priority => 3)
    dialstring = FXC::Dialstring.new(@user, [target1, target2, target3, target4], "error/do-not-call")
    dialstring.to_s.should.equal "[call-timeout=10]user/1909|user/1910,user/1911|user/1912"
  end
end
