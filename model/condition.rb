# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#

class FXC::Condition < Sequel::Model
  set_dataset FXC.db[:fs_conditions]
  one_to_many :actions, :class => 'FXC::Action'
  one_to_many :anti_actions, :class => 'FXC::AntiAction'
  many_to_one :context, :class => 'FXC::Context'
  plugin :list, :scope => :extension_id

  def break_string
    case self.break
    when nil 
      'never'
    when false
      'on-false'
    when true
      'on-true'
    end
  end
  protected
  def before_save
    base = FXC::Condition.filter(:extension_id => extension_id)
    base = base.filter(~{:id => self.id}) if self.id
    max = base.order(:position.asc).last.position rescue -1
    if self.position
      p = self.position.to_i
      if p > max
        self.position = max + 1
      else
        bigger = base.filter{|o| o.position >= p}
        bigger.update("position = (position + 1)")
      end
    else
      self.position = max + 1
    end
  end

end
