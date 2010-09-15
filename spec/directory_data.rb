# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require FXC::SPEC_HELPER_PATH/:db_helper

user1 = FXC::User.create(:extension => "1901", :pin => "2121", :mailbox => "1901")
user1.active = true
user1.save

user1.add_did(FXC::Did.new(:number => "1901", :clid_name => "Joe Smith", :description => "Inbound DID Test"))

user2 = FXC::User.create(:extension => "1902", :pin => "3131", :mailbox => "1902")
user2.active = true
user2.save

user2.add_did(FXC::Did.new(:number => "1902", :clid_name => "John Doe", :description => "Inbound DID Test #2"))

user2.add_target(FXC::Target.new(:value => "${sofia_contact(default/1902@${dialed_domain})}"))

user3 = FXC::User.create(:extension => "1903", :pin => "3131")
user3.active = true
user3.save

user3.add_did(FXC::Did.new(:number => "9044441234", :clid_name => "Jane Doe", :description => "Inbound DID Test #3"))
user3.add_target(FXC::Target.new(:value => "8173331111"))

vmail1 = FXC::Voicemail.create(:created_epoch => 1244584744, :read_epoch => 0, :username => "1901", :domain => "127.0.0.1", :uuid => "abcd-1234-efgh-5678", :cid_name =>"Joe", :cid_number=>"8675309", :in_folder=>"inbox", :file_path=>"/path/to/file.wav", :message_len=>28, :flags => "", :read_flags => "B_NORMAL")
