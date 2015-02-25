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

v2 = Skytap::VM.new(configuration_id: 3442128, template_id: 531869)

v2.save

puts "***" + v2.id