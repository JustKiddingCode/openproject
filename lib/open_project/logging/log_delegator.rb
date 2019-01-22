module OpenProject
  module Logging
    class LogDelegator
      class << self

        ##
        # Consume a message and let it be handled
        # by all handlers
        def log(exception, context = {})
          message =
            if exception.is_a? Exception
              context[:exception] = exception
              context[:backtrace] = clean_backtrace(exception)
              message = "#{exception}: #{exception.message}"
            else
              exception.to_s
            end

          # Set current contexts
          context[:level] ||= context[:exception] ? :error : :info
          context[:current_user] ||= User.current

          registered_handlers.each do |handler|
            handler.call message, context
          end

          nil
        end

        %i(debug info warn error fatal unknown).each do |level|
          define_method(level) do |*args|
            message = args.shift
            context = args.shift || {}

            log(message, context.merge(level: level))
          end
        end

        ##
        # Get a clean backtrace
        def clean_backtrace(exception)
          return nil unless exception&.backtrace
          Rails.backtrace_cleaner.clean exception.backtrace
        end

        ##
        # The active set of error handlers
        def registered_handlers
          @handlers ||= default_handlers
        end

        private

        def default_handlers
          [method(:rails_logger_handler)]
        end

        ##
        # A lambda handler for logging the error
        # to rails.
        def rails_logger_handler(message, context = {})
          Rails.logger.public_send(
            context[:level],
            message + context_string(context)
          )

          if backtrace = context[:backtrace]
            Rails.logger.debug { backtrace.join($/) }
          end
        end

        ##
        # Create a context string
        def context_string(context)
          ''.tap do |str|
            str << " [user=#{context[:user].id}]" if context[:user]
          end
        end
      end
    end
  end
end
