require 'logger'

module Skytap
  class Log
    class << self
      def logger
        unless @logger
          @log_path = STDOUT #File.join(Util.work_dir, "log.txt")
          puts "Using log path #{@log_path}"
          @logger = Logger.new(@log_path)
        end

        @logger
      end

      def content
        File.read(@log_path)
      end

      def exception(ex, during='')
        logger.error("Error #{during.empty? ? '' : 'while ' + during}: #{ex}\n#{ex.backtrace.join("\n")}")
      end

      def method_missing(method_sym, *arguments, &block) # pass through standard logger methods
        if logger.respond_to?(method_sym)
          logger.send(method_sym, *arguments, &block)
        else
          raise NoMethodError
        end
      end
    end
  end
end