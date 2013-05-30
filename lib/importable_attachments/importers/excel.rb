module ImportableAttachments
  module Importers
    module Excel

      require 'iconv'

      # :call-seq:
      # import_csv
      #
      # imports an Excel (tm) file

      def import_excel
        column_names = self.class.spreadsheet_columns
        assoc = self.class.import_into
        import_method = self.class.import_method
        return unless attachment.present?

        stream = attachment.io_stream
        stream_path = if stream.exists?
          stream.path
        else
          stream.queued_for_write[:original].path
        end
        spreadsheet = Roo::Excel.new stream_path

        spreadsheet.default_sheet = spreadsheet.sheets.first
        headers = (1..column_names.length).map { |n| spreadsheet.cell(1, n).try(:downcase) }
        return unless headers == column_names.map(&:downcase)
        self.send(assoc).destroy_all
        2.upto(spreadsheet.last_row) do |line|
          self.send(import_method, *(1..column_names.length).map { |n| spreadsheet.cell(line, n) })
        end
      end

    end
  end
end
