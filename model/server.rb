# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
class FXC::Server < Sequel::Model
  set_dataset FXC.db[:servers]
  one_to_many :contexts, :class => 'FXC::Context'
end
