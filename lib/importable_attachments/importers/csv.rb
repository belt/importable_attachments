module ImportableAttachments
  module Importers
    module Csv
      attr_accessor :validate_headers, :destructive_import

      # ImportInto suitable attributes translated from a ImportInto::ACTIVITY_RECORD_HEADERS
      # invertion, based on ACTIVITY_RECORD_HEADERS
      attr_accessor :converted_headers

      def initialize(params = {})
        bootstrap
        super params
      end

      # :call-seq:
      # bootstrap
      #
      # :validate_headers - ensures :spreadsheet_columns exist within file
      # :validate_on_import - validates :import_into records upon import (much slower)
      # :timestamp_import - sets timestamps of :import_into records upon import (mildly slower)
      # :destructive_import - makes :import_into reflect most recent file contents (slow)

      def bootstrap
        @import_rows_to_class = association_symbol_for_rows.to_s.classify.constantize
        @validate_headers = true
        @validate_on_import = true
        @destructive_import = true
        @timestamp_import = true
        @converted_headers = set_converted_headers
      end

      # :call-seq:
      # import_csv
      #
      # imports a comma-separated value file

      def import_csv
        return unless try(:attachment) && attachment.present?
        return unless validate_headers && !importable_class_headers_ok?
        transaction do
          send(association_symbol_for_rows).destroy_all if destructive_import
          #send import_method, Hash[importable_columns.zip(importable_columns)].symbolize_keys!
          import_rows Hash[importable_columns.zip(importable_columns)].symbolize_keys!
        end
      end

      # :call-seq:
      # import_rows params
      #
      # imports a CSV file into .people_collection_activity

      def import_rows(*fields)
        sanitize_data!
        sanitize_data_callback if respond_to? :sanitize_data_callback

        importer_opts = {}
        importer_opts.merge! timestamps: false # adds data to converted_headers and spreadsheet
        importer_opts.merge! validate: true

        # .dup else .import modifies coverted_headers and spreadsheet
        results = @import_rows_to_class.import converted_headers.dup, spreadsheet.dup, importer_opts
        reload

        if results && !results.try(:failed_instances).try(:empty?)
          opts = {}
          opts.merge! import_errors_valid: false

          fail_msg = "failed to import #{results.failed_instances.count} record(s)"
          logger.warn "#{klass.to_s} #{fail_msg}"

          results.failed_instances.each do |failed_row|
            err_msg = "#{failed_row.errors.messages}: #{failed_row.inspect}"
            logger.warn err_msg
            attachment.errors.add :base, err_msg unless opts[:import_errors_valid]
          end

          unless opts[:import_errors_valid]
            errors.add :attachment, 'invalid attachment'
            attachment.errors.add :base, fail_msg
          end
        end
      end

      protected

      # :call-seq:
      # set_converted_headers
      #
      # into model attributes representing has_many_attachments ACTIVITY_RECORD_HEADERS

      def set_converted_headers
        header_conversion_chart = @import_rows_to_class.const_get(:ACTIVITY_RECORD_HEADERS).invert
        @converted_headers = importable_columns.map { |col| header_conversion_chart[col] }
      end

      # :call-seq:
      # importable_columns
      #
      # enumeration of spreadsheet columns to import

      def importable_columns
        @column_names ||= self.class.spreadsheet_columns
      end

      # :call-seq:
      # association_symbol_for_rows
      #
      # symbol of association representing individual rows of the spreadsheet

      def association_symbol_for_rows
        @importing_reflection ||= self.class.import_into
      end

      # :call-seq:
      # import_method
      #
      # TODO: WRITE ME

      def import_method
        @import_method ||= self.class.import_method
      end

      # :call-seq:
      # spreadsheet
      #
      # the "raw" file as processed by CSV

      def spreadsheet
        @spreadsheet ||= if defined? FasterCSV
                           FasterCSV.read attachment.io_stream.path
                         else
                           CSV.read attachment.io_stream.path
                         end
      end

      # :call-seq:
      # headers
      #
      # headers for the spreadsheet

      def headers
        @headers ||= spreadsheet.shift
      end

      # :call-seq:
      # importable_class_headers_ok?
      #
      # requesting to import headers that are not found in the spreadsheet

      def importable_class_headers_ok?
        extra_headers = importable_columns.map(&:downcase) - headers
        unless extra_headers.empty?
          errors.add :base, "column(s) not found: #{extra_headers.join(', ')}"
          return
        end
      end

      # :call-seq:
      # sanitize_data!
      #
      # munge data as needed for import e.g. smarter_dates-ish integration

      def sanitize_data!
        convert_datetimes_intelligently!
      end

      # :call-seq:
      # convert_datetimes_intelligently!
      #
      # translates English date-ish and-or time-ish language into DateTime instances

      def convert_datetimes_intelligently!
        dt_attrs = converted_headers.select { |obj| obj.match(/_(?:dt?|at|on)\z/) }
        dt_idxs = dt_attrs.map { |obj| converted_headers.find_index(obj) }

        spreadsheet.map! { |row|
          dt_idxs.each { |idx| row[idx] = row[idx].try(:to_datetime) || row[idx] }
          row }
      end

    end
  end
end
