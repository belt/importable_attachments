module ImportableAttachments  # :nodoc:
  # validate attachment is a spreadsheet file
  class SpreadsheetValidator < ActiveModel::Validator

    # :call-seq:
    # validate :record
    #
    # ensures that the record's attachment file name has a supported extension
    # (.xls, .xlsx, .ods, .xml, .csv)

    def validate(record)
      extension = record.attachment.io_stream_file_name.split('.').last
      if !%w(xls xlsx ods xml csv).member?(extension)
        record.errors[:attachment] << 'File must be in a supported format (.xls, .xlsx, .ods, .xml, .csv)'
      end
    end

  end
end
