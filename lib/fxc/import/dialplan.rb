require_relative '../import'
require_relative '../../../spec/db_helper' # comment this out for production
require_relative '../../../model/init'

module FXC
  class Converter
    module Dialplan
      module_function

      def parse_context(node, server)
        name = node[:name]
        puts "Parsing context #{name} for server #{server}"
        # Add the context
        server  = FXC::Server.find_or_create(:name => server)
        context = FXC::Context.find_or_create(:server_id => server.id, :name => name)
        node.xpath("extension").each do |ext|
          parse_extension ext, context
        end
      end

      def parse_extension(node, context)
        name = node[:name]
        puts "Parsing extension #{name}"
        # Add the extension
        extension = FXC::Extension.find_or_create(
          :context_id => context.id,
          :name       => name,
          :continue   => node[:continue]
        )
        node.xpath("condition").each do |cond|
          parse_condition cond, extension
        end
      end

      def parse_condition(node, extension)
        field, expression = node[:field], node[:expression]
        puts "Parsing condition #{field} => #{expression}"
        # Add the condition
        condition = FXC::Condition.find_or_create(
          :extension_id => extension.id,
          :matcher        => field,
          :expression   => expression,
          :break        => node[:break],
          :name         => node[:name],
          :description         => node[:description]
        )
        node.xpath("action").each do |act|
          parse_action act, condition
        end
        node.xpath("anti-action").each do |act|
          parse_anti_action act, condition
        end
      end

      def parse_action(node, condition)
        app, data = node[:application], node[:data]
        puts "Parsing action #{app} => #{data}"
        # Add the action
        FXC::Action.find_or_create(
          :condition_id => condition.id,
          :application  => app,
          :data         => data
        )
      end

      def parse_anti_action(node, condition)
        app, data = node[:application], node[:data]
        puts "Parsing action #{app} => #{data}"
        FXC::AntiAction.find_or_create(
          :condition_id => condition.id,
          :application  => app,
          :data         => data
        )
      end
    end
  end
end
