module ImportableAttachments
  module AttachmentFormHelper

    # :call-seq:
    # io_stream_file_name_field_text object
    #
    # yields the filename or a please-upload something message

    def io_stream_file_name_field_text(obj)
      if obj.attachment.try(:io_stream_file_name)
        obj.attachment.io_stream_file_name
      else
        "Please upload a file"
      end
    end
  end
end
