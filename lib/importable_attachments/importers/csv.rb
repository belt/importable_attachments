module ImportableAttachments
  module Importers
    module Csv
      attr_accessor :validate_headers, :destructive_import, :validate_on_import

      # ImportInto suitable attributes translated from a ImportInto::RECORD_HEADERS
      # inversion, based on RECORD_HEADERS
      attr_accessor :converted_headers

      def initialize(attributes = nil, options = {})
        bootstrap
        super(attributes, options)
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
        @validate_on_import = ::Configuration.for('attachments').validate_on_import
        @destructive_import = true
        @timestamp_import = true
        @converted_headers = set_converted_headers
      end

      # :call-seq:
      # import_csv
      #
      # imports a comma-separated value file

      def import_csv
        return unless attachment.present?
        return if validate_headers && !importable_class_headers_ok?
        transaction do
          send(association_symbol_for_rows).destroy_all if destructive_import
          #send import_method, Hash[importable_columns.zip(importable_columns)].symbolize_keys!
          raise ActiveRecord::Rollback unless import_rows Hash[importable_columns.zip(importable_columns)].symbolize_keys!
        end
      end

      # :call-seq:
      # import_rows *params
      #
      # imports a CSV file into @import_rows_to_class

      def import_rows(*params)
        sanitize_data!

        importer_opts = {}
        importer_opts.merge! timestamps: true # adds data to converted_headers and spreadsheet
        importer_opts.merge! validate: validate_on_import

        # .dup else .import modifies converted_headers and spreadsheet
        if respond_to? :sanitize_data_callback
          headers, sheet = sanitize_data_callback(converted_headers, spreadsheet)
        else
          headers, sheet = converted_headers.dup, spreadsheet.dup
        end
        results = @import_rows_to_class.import headers, sheet, importer_opts
        reload if persisted?

        if results && !results.try(:failed_instances).try(:empty?)
          opts = {}
          opts.merge! import_errors_valid: false

          fail_msg = "failed to import #{results.failed_instances.count} record(s)"
          logger.warn "#{@import_rows_to_class.to_s} #{fail_msg}"

          @row_errors = results.failed_instances.map {|failed_row| "#{failed_row.errors.messages}: #{failed_row.inspect}"}
          return nil
        else
          @row_errors = []
          return results
        end

      end

      protected

      # :call-seq:
      # set_converted_headers
      #
      # into model attributes representing has_many_attachments RECORD_HEADERS

      def set_converted_headers
        header_conversion_chart = @import_rows_to_class.const_get(:RECORD_HEADERS).invert
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
      # read_spreadsheet
      #
      # the "raw" file as processed by CSV

      def read_spreadsheet
        csv_klass = (defined? FasterCSV) ? FasterCSV : CSV
        stream = attachment.io_stream
        if stream.exists?
          csv_klass.read stream.path
        else
          csv_klass.read stream.queued_for_write[:original].path
        end
      end

      # :call-seq:
      # spreadsheet
      #
      # the rows of the file after the first row (headers)

      def spreadsheet
        read_spreadsheet[1..-1]
      end

      # :call-seq:
      # headers
      #
      # headers for the spreadsheet

      def headers
        read_spreadsheet.first
      end

      # :call-seq:
      # importable_class_headers_ok?
      #
      # requesting to import headers that are not found in the spreadsheet

      def importable_class_headers_ok?
        extra_headers = importable_columns.map(&:downcase) - headers
        if extra_headers.empty?
          @columns_not_found = nil
          return true
        else
          @columns_not_found = extra_headers.join(', ')
          return false
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
