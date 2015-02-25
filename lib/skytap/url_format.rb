require 'recursive_open_struct'

module Skytap
	class URLFormat
		def initialize(url_format_str)
			@url_format_str = url_format_str
		end

		def to_s
			@url_format_str
		end

		def argify(url_args)
			url_args ||= {}
			url_args = url_args.to_h if url_args.is_a?(RecursiveOpenStruct)
    	provided_arg_names = url_args.keys.map {|key| key.to_sym}
    	missing = missing_arg_names(provided_arg_names)
    	raise "Missing URL arguments: #{missing}" unless missing.empty?

    	@url_format_str.split('/').map {|token|
    		token.start_with?(':') ? url_args[token[1..-1].to_sym] : token
    	}.join('/')
    end

    def required_arg_names
    	@url_format_str.split('/').select {|token| token.start_with?(':')}.map {|token| token[1..-1].to_sym}.uniq
		end

		#TODO -- These take in Openstructs and return hashes - that's weird

		def required_args(args)
			args.to_h.select {|k,v| required_arg_names.include?(k)}
		end

		def unneeded_args(args)
			args.to_h.reject {|k,v| required_arg_names.include?(k)}
		end

		def missing_arg_names(arg_names)
			required_arg_names-arg_names
		end
	end
end