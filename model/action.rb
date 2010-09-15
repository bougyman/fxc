# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#

class FXC::Action < Sequel::Model
  set_dataset FXC.db[:fs_actions]
  many_to_one :condition, :class => 'FXC::Condition'
  plugin :list, :scope => :condition_id

  protected
  def before_save
    base = FXC::Action.filter(:condition_id => self.condition_id)
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
