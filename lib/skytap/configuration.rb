module Skytap
	class Configuration < Resource
		has_many :vms, class_name: 'VM'
	end
end