# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require_relative '../lib/fxc'
require FXC::LIBROOT/:fxc/:db
raise "No DB Available" unless FXC.db

require 'makura'
Makura::Model.database = 'fxc'

# Here go your requires for models:
require_relative 'user'
require_relative 'user_variable'
require_relative 'target'
require_relative 'did'
require_relative 'provider'
require_relative 'context'
require_relative 'voicemail'
#require "sequel_orderable"
require_relative 'extension'
require_relative 'condition'
require_relative 'action'
require_relative 'anti_action'
require_relative 'configuration'
