module Skytap
	class VM < Resource
		collection_url_formatted_as "/configurations/:configuration_id/vms"
		belongs_to :configuration		

		def configuration_id
			@properties['configuration_id'] || @properties['configuration_url'].split('/').last
		end

		def save_new_record
			config = self.configuration
			existing_vm_ids = config.vms.map {|vm| vm.id}
			
			config.put(template_id: @properties.template_id)
			new_vm_ids = config.vms.map {|vm| vm.id}
			@properties.id = (new_vm_ids-existing_vm_ids).first
		end
	end
end