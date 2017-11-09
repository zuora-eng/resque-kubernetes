require "resque"

module Resque
  module Kubernetes
    module Worker
      def self.included(base)
        base.class_eval do
          prepend InstanceMethods
        end
      end

      attr_accessor :term_on_empty

      module InstanceMethods
        def prepare
          self.term_on_empty = ENV["TERM_ON_EMPTY"] if ENV["TERM_ON_EMPTY"]
          super
        end

        if Gem::Specification::find_all_by_name('resque-pool').any?
          def shutdown_with_pool?
            if term_on_empty
              if queues_empty?
                log_with_severity :info, "shutdown: queues are empty"
                shutdown
              end
            end

            super
          end
        else
          def shutdown?
            if term_on_empty
              if queues_empty?
                log_with_severity :info, "shutdown: queues are empty"
                shutdown
              end
            end

            super
          end
        end
      end


      private

      def queues_empty?
        queues.all? { |queue| Resque.size(queue) == 0 }
      end

    end
  end
end
