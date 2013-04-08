module ImportableAttachments
  module Importers
    module Csv

      # :call-seq:
      # import_csv
      #
      # imports a comma-separated value file

      def import_csv
        column_names = self.class.spreadsheet_columns
        assoc = self.class.import_into
        import_method = self.class.import_method
        return unless try(:attachment) && attachment.present?
        spreadsheet = if defined? FasterCSV
                        FasterCSV.read attachment.io_stream.path
                      else
                        CSV.read attachment.io_stream.path
                      end
        headers = spreadsheet.shift
        return unless headers == column_names.map(&:downcase)
        self.send(assoc).destroy_all # TODO: make destructive import optional
        rows = Hash[(column_names.map { |str| str.to_sym }).zip(fields)] # TODO: symbolize_keys!
        self.send import_method, rows
      end

    end
  end
end
