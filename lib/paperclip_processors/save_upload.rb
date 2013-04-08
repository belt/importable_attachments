require 'paperclip'

module Paperclip

# force older versions of Paperclip::Upfile to be idempotent
# https://github.com/thoughtbot/paperclip/issues/315
  class SaveUpload < Processor
    # :call-seq:
    # initialize file, opts, attachment
    #
    # file       : File:/tmp/stream_stuff.xls
    # opts       : has_attached_file(:processors,:attachment_attr)
    # attachment : Paperclip::Attachment

    def initialize(file, options = {}, attachment = nil)
      @attachment = attachment
      @file = file
    end

    # :call-seq:
    # make
    #
    # called by paperclip after_save

    def make
      @file.read(1)
      @file.rewind
      @file
    end

  end
end

