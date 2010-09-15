# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../app', __FILE__)
require 'nokogiri'
require 'innate/spec/bacon'
Innate::Log.loggers = [Logger.new(FXC::ROOT/:log/"innate.log")]
Innate.middleware! :spec do |m|
  m.use Rack::Lint
  m.use Rack::CommonLogger, Innate::Log
  m.use FXC::Rack::Middleware
  m.innate
end

Innate.options.roots = [FXC::ROOT]
