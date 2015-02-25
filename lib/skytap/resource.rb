require 'active_support/core_ext/string/inflections'

module Skytap
	class Resource
		def put(body=nil)
			@api_properties = API.put(url, body)
		end

		def post(body=nil)
			@api_properties = API.post(url, body)
		end

		def get
			@api_properties = API.get(url)
		end

		def delete
			@api_properties = API.delete(url)
		end

		def self.belongs_to(resource_name, opts={})
			resource_class = "Skytap::#{(opts[:class_name] || resource_name).to_s.classify}".constantize
			define_method(resource_name) do
				args = {id: self.properties["#{resource_name}_id".to_sym]}
				resource_url = resource_class.object_url_format.argify(args)
				resource_class.new(resource_url)
			end
		end

		def self.has_many(resource_name_plural, opts={})
			resource_class = "Skytap::#{(opts[:class_name] || resource_name_plural.to_s.singularize).to_s.classify}".constantize
			define_method(resource_name_plural) do
				puts properties.send(resource_name_plural)
				properties.send(resource_name_plural).map do |resource_info|
					args = {id: resource_info.id, "#{self.class.resource_name}_id".to_sym => self.id}
					puts "The args are #{args}"
					resource_url = resource_class.object_url_format.argify(args)
					resource_class.new(resource_url)
				end
			end
		end

		def self.custom_property(name, args)
			define_method(name, args[:calculated_with])

			@custom_property_names ||= []
			@custom_property_names << name
		end

		def self.custom_property_names
			@custom_property_names
		end

		def custom_properties
			self.class.custom_property_names ? self.class.custom_property_names.map {|name| [name, self.send(name)]}.to_h : {}
		end

		def self.get(url_args={})
			API.get(collection_url_format.argify(url_args))
		end

		def self.post(url_args={}, body=nil)
			API.post(collection_url_format.argify(url_args), body)
		end

		def self.object_urls_formatted_as(fmt)
			@object_url_format = URLFormat.new(fmt)
		end

		def self.collection_url_formatted_as(fmt)
			@collection_url_format = URLFormat.new(fmt)
		end

		def self.object_url_format
			@object_url_format ||= URLFormat.new("#{collection_url_format.to_s}/:id")
		end

		def self.collection_url_format
			@collection_url_format ||= URLFormat.new("/#{self.pluralized_resource_name}")
		end

		def self.find(id, args={})
			args = args.merge({id: id})
			new(object_url_format.argify(args))
		end

		def properties
			RecursiveOpenStruct.new(
				@api_properties.to_h.merge(custom_properties),
				recurse_over_arrays: true
			)
		end

		def initialize(args)
			if args.is_a?(String) #URL
				@api_properties = API.get(args)
				not_new_record!
			else
				@api_properties = RecursiveOpenStruct.new(args, recurse_over_arrays: true)
				new_record!
			end
		end

		def refresh
			raise "Object has not been saved yet" if new_record?
			#properties = API.get(url)
			@api_properties = get
		end

		def url
			self.class.object_url_format.argify(properties)
		end

		def collection_url
			collection_url_format.argify(properties)
		end

		def save
			if new_record?
				save_new_record
				not_new_record!
			elsif dirty?
				save_dirty_record
				not_dirty!
			end
		end

		def save_new_record
			@api_properties = post(
				self.class.collection_url_format.unneeded_args(properties)
			)
		end

		def save_dirty_record
			#API.put(@url, dirty_properties)
			put(dirty_properties)
		end

		def dirty?
			@dirty_property_names && !@dirty_property_names.empty?
		end

		def dirty!(property_name)
			@dirty_property_names ||= []
			@dirty_property_names << property_name
		end

		def new_record?
			@new_record
		end

		def new_record!
			@new_record = true
		end

		def not_dirty!
			@dirty_property_names = []
		end

		def not_new_record!
			@new_record = false
		end

		private 

		def dirty_properties
			@dirty_property_names ? @dirty_property_names.map {|prop_name| [prop_name, @api_properties[prop_name]]}.to_h : nil
		end

		def method_missing(method_sym, *arguments, &block)
			#TODO This should also access custom properties
			if @api_properties.respond_to?(method_sym)
				if (method_sym.to_s.end_with?('='))
					property_name = method_sym.to_s.chomp('=').to_sym

					if @api_properties[property_name] != arguments.first
						dirty!(property_name)
					else
						return
					end
				end

				@api_properties.send(method_sym, *arguments, &block)
			else
				raise NoMethodError.new(method_sym.to_s)
			end
	  end

		def self.resource_name
			self.name.split('::').last.downcase
		end

		def self.pluralized_resource_name		
			self.resource_name.pluralize
		end
	end
end