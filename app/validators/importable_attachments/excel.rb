module ImportableAttachments  # :nodoc:
  # validate attachment is an excel file
  class ExcelValidator < ActiveModel::Validator

    # :call-seq:
    # validate :record
    #
    # ensures that the record's attachment file name has a .xls extension

    def validate(record)
      extension = record.attachment.io_stream_file_name.split('.').last
      if extension != 'xls'
        record.errors[:attachment] << 'File must be an Excel (.xls) file'
      end
    end

  end
end
