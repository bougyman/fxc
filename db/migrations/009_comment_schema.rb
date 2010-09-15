# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    execute("COMMENT ON TABLE schema_info IS E'Migration info is stored here'")
    execute("COMMENT ON COLUMN schema_info.version IS E'The current migration version'")
    execute("COMMENT ON TABLE targets IS E'Store the endpoints which calls can be redirected to here'")
    execute("COMMENT ON COLUMN targets.user_id IS E'A user target, references users.id'")
    execute("COMMENT ON COLUMN targets.did_id IS E'A DID target, references dids.id'")
    execute("COMMENT ON TABLE dids IS E'Store each indbound DID (Direct Inward Dial) we accept here'")
    execute("COMMENT ON COLUMN dids.clid_name IS E'The name to send when redirecting calls from this DID'")
    execute("COMMENT ON TABLE users IS E'Store each user of the system here'")
    execute("COMMENT ON COLUMN users.username IS E'Store the extension here'")
    execute("COMMENT ON COLUMN users.mailbox IS E'The mailbox shortcut for a user'")
    execute("COMMENT ON COLUMN users.dialstring IS E'The default dialstring for a user'")
    execute("COMMENT ON COLUMN users.password IS E'The password to authenticate the username to FreeSWITCH (SIP/MENUS)'")
    execute("COMMENT ON COLUMN users.\"vm-password\" IS E'The password to authenticate the username to voicemail'")
    execute("COMMENT ON COLUMN users.cidr IS E'The cidr mask a user can authenticate from'")
    execute("COMMENT ON TABLE user_variables IS E'Variables for each user are stored here as key/value pairs'")
    execute("COMMENT ON COLUMN user_variables.value IS E'The variable''s value'")
  end

  def down
  end
end
