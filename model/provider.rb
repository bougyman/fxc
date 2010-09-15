# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
class FXC::Provider < Sequel::Model(FXC.db[:providers])
  def format(number)
    number.match(/^\d{10}$/) ? "sofia/external/#{format_s % number}#{port ? ":#{port}" : ""}" : number
  end

  @scaffold_human_name = 'Provider'
  @scaffold_column_types = {}

  private

  def format_s
    "%s%%s@%s" % [prefix, host]
  end
end
