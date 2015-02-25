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
	autoload :Template, 'skytap/template'
	autoload :Network, 'skytap/network'
end

# v = Skytap::VM.find(4685072, configuration_id: 3442128)
# v.name = 'THE NAME CHANGE GOES HERE 6'
# v.save

# #c = v.configuration
# c = Skytap::Configuration.find(3442128)
# puts c.class
# puts c.name
# puts c.vms

# Adding a single-VM template to a config. (Note: this will do something weird if there were multiple VMs in the template...)
v2 = Skytap::VM.new(configuration_id: 3442128, template_id: 531869)
v2.save
puts v2.id

# c = Skytap::Configuration.new(template_id: 531869)
# c.save
# puts c.id
# c.runstate = 'running'
# c.save

# v = Skytap::VM.find(4702040, configuration_id: 3454828)
# v.runstate = 'suspended'
# v.save

# t  = Skytap::Template.new
# t.configuration_id = 3454828
# t.youcanignoerthis = 42
# t.name = "THAT TEMPLATE I MADE, AGAIN!"
# t.save
# puts t.id

# c = Skytap::Configuration.find(3454828)
# n = c.networks.first
# n.name = 'foonet'
# n.save
