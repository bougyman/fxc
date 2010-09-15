# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)

describe 'FXC::Voicemail' do

  it 'should output parsed epoch_time in UTC' do
    v = FXC::Voicemail.create(:created_epoch => 1244584744)
    v.timestamp.should.equal "06/09/2009 21:59"
    FXC::Voicemail.filter(:uuid => v.uuid, :username => v.username, :created_epoch => v.created_epoch).delete
  end

end
