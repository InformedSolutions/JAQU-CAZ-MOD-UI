# frozen_string_literal: true

# allow to use nulldb adapter
# :nocov:
module ActiveRecord
  module ConnectionAdapters
    class NullDBAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
      def new_table_definition(table_name = nil, is_temporary = nil)
        TableDefinition.new(table_name, is_temporary)
      end
    end
  end

  # https://github.com/nulldb/nulldb/pull/88/files
  module Tasks
    class NullDBDatabaseTasks
      def initialize(configuration)
        @configuration = configuration
      end

      def create(_ = false)
        # NO-OP
      end

      def drop
        # NO-OP
      end

      def purge
        # NO-OP
      end

      def structure_dump(_, _)
        # NO-OP
      end

      def structure_load(_, _)
        # NO-OP
      end

      def clear_active_connections!
        # NO-OP
      end
    end
  end
end

ActiveRecord::Tasks::DatabaseTasks.register_task(/nulldb/,
                                                 ActiveRecord::Tasks::NullDBDatabaseTasks)
# :nocov:
