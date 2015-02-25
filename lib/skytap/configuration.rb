module Skytap
	class Configuration < Resource
		has_many :vms, class_name: 'VM'
		has_many :networks
	end
end