require 'makura'
require 'pp'

module FXC
  class Converter
    module Directory
      module_function

      def parse_domain(node, doc, couchdb)
        doc[:name] = domain = node[:name]
        server = doc[:server]
        doc["_id"] = "%s_%s.domain" % [server, domain]
        doc[:type] = "directory"
        
        doc[:params] = params = {}
        node.xpath('params/param').each do |param|
          params[param[:name]] = param[:value]
        end
        
        doc[:variables] = variables = {}
        node.xpath('variables/variable').each do |variable|
          variables[variable[:name]] = variable[:value]
        end

        doc[:groups] = groups = []
        node.xpath('groups/group').each do |group|
          groups << group[:name]
          grp = {server: server, 
                 domain: domain,
                 name: group[:name],
                 type: "group",
                 members: []}
          grp["_id"] = "%s_%s_%s.group" % [server, domain, grp[:name]]
          #couchdb.save(grp)
          group.xpath('users/user').each do |user|
            if user[:type] == "pointer"
              grp[:members] << user[:id]
            else
              u = parse_user(user, grp)
              grp[:members] << u[:id] unless grp[:members].include?(u[:id])
              rec = couchdb.save(u)
              p rec
            end
          end
          rec = couchdb.save(grp)
          p rec
        end

        doc
      end

      def parse_user(node, group_doc)
        #users[node[:id]] = user = {}
        server, domain, group = group_doc[:server], group_doc[:domain], group_doc[:name]
        user = {type: 'user', server: server, group: group, domain: domain}
        user[:id]   = node[:id]
        user["_id"] = "%s_%s_%s_%s.user" % [server, domain, group, user[:id]]

        # node is a user, user is the hash representation
        user[:params] = params = {}
        node.attributes.each do |key, value|
          params[key] = value unless key == "id"
        end
        node.xpath('params/param').each do |param|
          params[param[:name]] = param[:value]
        end

        user[:variables] = variables = {}
        node.xpath('variables/variable').each do |variable|
          variables[variable[:name]] = variable[:value]
        end

        user[:buttons] = buttons = {}
        node.xpath('skinny/buttons/button').each do |button|
        # p button[:position]          
          buttons[button[:position]] = sb = {}
          button.attributes.each do |key, attribute|
            sb[key] = attribute.value unless key == "position"
          end
        end

        user[:gateways] = gateways = {}
        node.xpath('gateways/gateway').each do |gateway|
          gateways[gateway[:id]] = gateway[:id]
          gateways[:params] = gparams = {}
          node.xpath('param').each do |param|          
            gparams[param[:name]] = param[:value]
          end
        end

        user 
      end


     def default(xml, doc = {})   
        doc[:params] = params = {}
        doc[:groups] = groups = {}
        doc[:variables] = variables = {}
        doc[:name] = xml[:name]
        xml.xpath('params/param').each do |param|
          params[param[:name]] = param[:value]
        end

        xml.xpath('variables/variable').each do |variable|
          variables[variable[:name]] = variable[:value]
        end
        
        doc[:groups] = groups = {}
        xml.xpath('groups/group').each do |group|
          p group[:name]
          groups[group[:name]] = us = {}
          group.xpath('users/user').each do |user|
            p user
            us[user[:id]] = user[:type]
          end
        end

        p doc.to_s
        doc
      end


=begin
      def xml_curl(xml, doc)
        doc[:bindings] = bindings = {}

        xml.xpath('bindings/binding').each do |binding|
          bindings[binding[:name]] = params = {}

          binding.xpath('param').each do |param|
            if param[:name] == 'gateway-url'
              params[:config] = {
                'gateway-url' => param[:value],
                'bindings' => param[:bindings],
              }
            else
              params[param[:name]] = param[:value]
            end
          end
        end
      end

      def console(xml, doc)
        doc[:mappings] = mappings = {}
        xml.xpath('mappings/map').each do |map|
          mappings[map[:name]] = map[:value]
        end

        _settings(xml, doc)
      end

      def logfile(xml, doc)
        doc[:profiles] = profiles = {}
        xml.xpath('profiles/profile').each do |profile|
          profiles[profile[:name]] = ph = {}
          _settings(profile, ph)
          ph[:mappings] = pm = {}
          profile.xpath('mappings/map').each do |map|
            pm[map[:name]] = map[:value].scan(/[^\s,]+/)
          end
        end

        _settings(xml, doc)
      end

      def enum(xml, doc)
        _settings(xml, doc)
        doc[:routes] = routes = []
        xml.xpath('routes/route').each do |route|
          routes << route.attributes
        end
      end

      def xml_cdr(xml, doc)
        doc[:description] = 'XML CDR cURL Logger'
        _settings(xml, doc)
      end

      def cdr_csv(xml, doc)
        doc[:description] = 'CDR CSV Format'
        _settings(xml, doc)
        doc[:templates] = templates = {}
        xml.xpath('templates/template').each do |template|
          templates[template[:name]] = template.inner_text
        end
      end

      def event_socket(xml, doc)
        doc[:description] = 'Socket Client'
        _settings(xml, doc)
      end

      def sofia(xml, doc)
        doc[:global_settings] = global_settings = {}
        xml.xpath('global_settings/param').each do |param|
          global_settings[param[:name]] = param[:value]
        end

        doc[:profiles] = profiles = {}
        xml.xpath('profiles/profile').each do |profile|
          profiles[profile[:name]] = ph = {}
          _settings(profile, ph)

          ph[:aliases] = profile.xpath('aliases').map{|a| a[:name] }
          ph[:domains] = domains = {}
          profile.xpath('domains/domain').each do |domain|
            domains[domain[:name]] = {
              alias: domain[:alias] == 'true',
              parse: domain[:parse] == 'true',
            }
          end

          ph[:gateways] = gateways = {}

          xml.xpath('gateways/gateway').each do |gateway|
            gateways[gateway[:name]] = gh = {}
            gateway.xpath('param').each do |param|
              gh[param[:name]] = param[:value]
            end
          end
        end
      end

      def conference(xml, doc)
        doc[:advertise] = advertise = {}
        xml.xpath('advertise/room').each do |room|
          advertise[room[:name]] = room[:status]
        end

        doc['caller-controls'] = caller_controls = {}
        xml.xpath('caller-controls/group').each do |group|
          caller_controls[group[:name]] = gh = {}
          group.xpath('control').each do |control|
            gh[control[:action]] = control[:digits]
          end
        end

        doc['profiles'] = profiles = {}
        xml.xpath('profiles/profile').each do |profile|
          profiles[profile[:name]] = ph = {}
          profile.xpath('param').each do |param|
            ph[param[:name]] = param[:value]
          end
        end
      end

      def fifo(xml, doc)
        _settings(xml, doc)

        doc['fifos'] = fifos = {}
        xml.xpath('fifos/fifo').each do |fifo|
          fifos[fifo[:name]] = fh = {}
          fifo.attributes.each do |key, attribute|
            fh[key] = attribute.value unless key == "name"
          end

          fh[:members] = members = {}
          fifo.xpath('member').each do |member|
            members[member.text] = mh = {}
            member.attributes.each do |key, attribute|
              mh[key] = attribute.value
            end
          end
        end
      end

      def db(xml, doc)
        _settings(xml, doc)
      end

      def hash(xml, doc)
        doc[:remotes] = remotes = {}
        xml.xpath('remotes/remote').each do |remote|
          remotes[remote[:name]] = rh = {}
          remote.attributes.each do |key, attribute|
            rh[key] = attribute.value unless key == 'name'
          end
        end
      end

      def local_stream(xml, doc)
        doc[:directories] = directories = {}
        xml.xpath('directory').each do |directory|
          directories[directory[:name]] = dh = {}
          dh[:path] = directory[:path]
          directory.xpath('param').each do |param|
            dh[param[:name]] = param[:value]
          end
        end
      end

      def spandsp(xml, doc)
        doc[:descriptors] = descriptors = {}
        xml.xpath('descriptors/descriptor').each do |descriptor|
          descriptors[descriptor[:name]] = dh = {}
          descriptor.xpath('tone').each do |tone|
            dh[tone[:name]] = ta = []
            tone.xpath('element').each do |element|
              ta << tah = {}
              element.attributes.each do |key, attribute|
                tah[key] = attribute.value.to_i
              end
            end
          end
        end
      end

      def voicemail(xml, doc)
        _settings(xml, doc)

        doc[:profiles] = profiles = {}
        xml.xpath('profiles/profile').each do |profile|
          profiles[profile[:name]] = ph = {}

          profile.xpath('param').each do |param|
            ph[param[:name]] = param[:value]
          end

          ph[:email] = email = {}
          profile.xpath('email/param').each do |param|
            email[param[:name]] = param[:value]
          end
        end
      end

      def _settings(xml, doc)
        doc[:settings] = settings = {}
        xml.xpath('settings/param').each do |param|
          settings[param[:name]] = param[:value]
        end
      end
=end
    end
  end
end
