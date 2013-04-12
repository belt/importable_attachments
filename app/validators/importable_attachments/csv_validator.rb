require 'csv'

# validate attachment is a CSV file
module ImportableAttachments  # :nodoc:
  class CsvValidator < ActiveModel::Validator

    # :call-seq:
    # validate :record
    #
    # ensures that the record's attachment file name has a .xls extension

    def validate(record)
      extension = record.attachment.io_stream_file_name.split('.').last
      if extension.downcase != 'csv'
        record.errors.add :attachment, 'invalid attachment'
        record.attachment.errors.add :base, 'File must be a CSV (.csv) file'
      end

      if defined? FasterCSV
        begin
          FasterCSV.read record.attachment.io_stream
        rescue FasterCSV::MalformedCSVError => err
          record.errors.add :attachment, 'invalid attachment'
          record.attachment.errors.add :base, err.messages.join(', ')
        end
      else
        begin
          CSV.read record.attachment.io_stream.path
        rescue CSV::MalformedCSVError => err
          record.errors.add :attachment, 'invalid attachment'
          record.attachment.errors.add :base, err.messages.join(', ')
        end
      end
    end
  end
end
