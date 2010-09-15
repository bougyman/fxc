# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path("../../lib/fxc", __FILE__)
require FXC::ROOT/:lib/:fxc/:dialstring
require "digest/sha1"
class FXC::User < Sequel::Model(FXC.db[:users])
  one_to_many :user_variables, :class => 'FXC::UserVariable'
  one_to_many :targets, :class => 'FXC::Target'
  one_to_many :dids, :class => 'FXC::Did'
  many_to_one :context, :class => 'FXC::Context'

  @scaffold_human_name = 'User'
  @scaffold_column_types = {
    :cidr => :string,
    :email => :string,
    :first_name => :string,
    :last_name => :string,
    :timezone => :string,
    :mailbox => :string,
    :dialstring => :string,
    :password => :string,
  }

  def scaffold_name
    "#{display_name} (#{username})"
  end

  def fullname
    [first_name, last_name].join(" ")
  end

  def dialstring
    pk ? FXC::Dialstring.new(self, targets).to_s : ''
  end

  def default_variables
    @_d_v ||= [
      [:user_context, :default],
      [:accountcode, username],
      [:toll_allow, "domestic,international,local"],
      [:effective_caller_id_number, username],
      [:effective_caller_id_name, fullname]
    ]
  end

  def set_default_variables
    update(:mailbox => extension) if mailbox.nil?
    FXC::Context.default.add_user(self) if context.nil?
    default_variables.each do |var|
      name, value = var.map { |s| s.to_s }
      if current = user_variables.detect { |d| d.name == name }
        current.value = value
        current.save
      else
        add_user_variable(FXC::UserVariable.new(:name => name, :value => value))
      end
    end
  end

  def self.active_users
    filter(:active => true)
  end

  # auth related stuff
  #
  # id may be email or username, but password has to be given for either.
  def self.authenticate(creds)
    id, password = creds.values_at(:id, :password)
    filter({:username => id} | {:email => id}).
      and(:password => digestify(password)).limit(1).first
  end

  def self.digestify(pass)
    Digest::SHA1.hexdigest(pass.to_s)
  end

  def password=(other)
    values[:password] = ::FXC::User.digestify(other)
  end

  protected
  def after_create
    set_default_variables
  end

  def validate
    if new?
      @errors.add(:extension, "can not be directly assigned above 3175") if extension and extension > 3175
    end
    if me = FXC::User[:extension => extension]
      @errors.add(:extension, "can not be duplicated") unless self[:id] and me[:id] == self[:id]
    end
    if username and my_user = FXC::User[:username => username]
      @errors.add(:username, "can not be duplicated") unless self[:id] and my_user[:id] == self[:id]
    end
    @errors.add(:email, "must be a valid email address") unless email.to_s.match(/^(?:[^@\s]+?@[^\s@]{6,})?$/)
    @errors.add(:pin, "must be all digits (4 minimum)") unless pin.to_s.match(/^(?:\d\d\d\d+)?$/)
    @errors.add(:extension, "must be all digits (4 minimum)") unless extension.to_s.match(/^(?:\d\d\d\d+)?$/)
    @errors.add(:mailbox, "must be all digits (4 minimum)") unless mailbox.to_s.match(/^(?:\d\d\d\d+)?$/)
  end
end
