require 'json'
require 'recursive_open_struct'

module Skytap
	class Settings
		def self.read(filename)
			@@settings = RecursiveOpenStruct.new(
				JSON.parse(File.read(filename)), recurse_over_arrays: true
			)
		end

		def self.method_missing(method_sym, *arguments, &block)
	  	raise "Settings not loaded" unless defined?(@@settings)
	  	@@settings.send(method_sym, *arguments, &block)
	  end
	end
end