module Skytap
	class Network < Resource
		belongs_to :configuration
		collection_url_formatted_as "/configurations/:configuration_id/networks"
	end
end