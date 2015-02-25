$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'skytap/settings'
Skytap::Settings.read('config/settings.json')

require 'skytap/api'
require 'skytap/url_format'
require 'skytap/resource'

#TODO This seems really weird
module Skytap
	autoload :Configuration, 'skytap/configuration'
	autoload :VM, 'skytap/vm'
end

# v = Skytap::VM.find(4685072, configuration_id: 3442128)

# v.name = 'THE NAME CHANGE GOES HERE 6'

# v.save

# puts "what are the odds???"
# #c = v.configuration

# c = Skytap::Configuration.find(3442128)
# puts c.class
# puts c.name

# puts c.vms

# turns out the api doesn't even support this! does this weird "Merge Template into Config" thing and the docs are wrong...
# should figure out how that works
# Need to do basically the below, only using put instead of post.
#oh, except you don't post it to /vms either. UGH.
# basically, need framework where you have
# Action		Method		URI
# with overridable defaults for each.
# e.g.  perform :create, via: :put, to: "/confiurations/:configuration_id"
#... or just implement new save method in subclasses?

v2 = Skytap::VM.new(configuration_id: 3442128, template_id: 531869)

v2.save

puts "***" + v2.id