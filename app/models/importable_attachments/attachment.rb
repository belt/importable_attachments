require 'filemagic'
require 'mime/types'
require 'paper_trail'
require 'paperclip'
require 'smarter_dates'
#require File.join(File.dirname(__FILE__), '../..', 'config/initializers/0_configuration')

# An attachment represents a file within the system.
module ImportableAttachments
  class Attachment < ActiveRecord::Base
    self.abstract_class = true
    self.table_name = :importable_attachments_attachments

    include SmarterDates if ::Configuration.for('smarter_dates').enabled
    include Rails::MarkRequirements if ::Configuration.for('mark_requirements').enabled

    if ::Configuration.for('versioning').enabled
      has_paper_trail ignore: [:updated_at], class_name: 'ImportableAttachments::Version'
    end

    # url for client downloadable content
    if ::Configuration.for('attachments').enabled
      include Paperclip::Glue
      if ::Configuration.for('attachments').include_revision_in_filename
        CONTENT_URL = ::Configuration.for('versioned').url
        CONTENT_PATH = ::Configuration.for('versioned').path
      else
        CONTENT_URL = ::Configuration.for('attachments').url
        CONTENT_PATH = ::Configuration.for('attachments').path
      end

      has_attached_file :io_stream, :url => CONTENT_URL, :path => CONTENT_PATH,
        :styles => {original: {io_stream_attr: :attach}},
        :processors => [:save_upload]
    end

    # --------------------------------------------------------------------------
    # define: attributes and relationships
    belongs_to :attachable, :polymorphic => true

    # --------------------------------------------------------------------------
    # define: aliases and delegations
    delegate :url, :to => :io_stream, :prefix => true

    # --------------------------------------------------------------------------
    # define: DTD i.e. validations

    # NOTE: to save nested-model forms, new instances must be valid. Therefore,
    #       attachable_id = nil must be valid when attachable is != nil
    validates :attachable_id, :if => :attachable_id?,
      :numericality => {only_integer: true, greater_than: 0}

    validates :attachable_type, alpha_numeric: {punctuation: true}, existing_class: true, :if => :attachable_type?

    validates_attachment :io_stream, :presence => true,
      :size => {greater_than: 0}

    validates :io_stream_file_name, :presence => true,
      :alpha_numeric => {punctuation: true}

    validates :io_stream_file_size, :presence => true,
      :numericality => {only_integer: true, greater_than_or_equal_to: 0}

    validates :io_stream_content_type, :presence => true,
      :alpha_numeric => {punctuation: true}

    validates :io_stream_updated_at, :chronic_parsable => true,
      :if => :io_stream_updated_at?

    # --------------------------------------------------------------------------
    # define: scopes

    attr_accessible :attachable_id, :attachable_type
    attr_accessible :io_stream
    attr_accessible :io_stream_file_name, :io_stream_content_type, :io_stream_file_size,
      :io_stream_updated_at

    # --------------------------------------------------------------------------
    # define: behaviors

    # :call-seq:
    # revision_number
    #
    # yields an integer representing the version-index
    #
    # NOTE: paper_trail manages version-tracking automatically

    def revision_number
      ver = version
      case
      when live? then
        versions.count
      when ver then
        ver.index
      else
        0
      end
    end

    # :call-seq:
    # io_stream_mime_type
    #
    # yields the files MIME::Type

    def io_stream_mime_type
      mime = new_record? ? io_stream.content_type : magic_mime_type
      MIME::Types[mime].first
    end

    # :call-seq:
    # magic_mime_type
    #
    # yields a saved attachments mime_type according to libmagic

    def magic_mime_type
      return if new_record?
      return unless File.exists? io_stream.path
      FileMagic.mime.file(io_stream.path).split(/;\s*/).first
    end

  end
end

# == Schema Information
#
# Table name: attachments
#
#  id                     :integer          not null, primary key
#  attachable_type        :string(255)
#  attachable_id          :string(255)
#  io_stream_file_name    :string(255)
#  io_stream_content_type :string(255)
#  io_stream_file_size    :integer
#  io_stream_updated_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  idx_importable_attachments_on_attachable_type_and_id  (attachable_type,attachable_id)
#  index_attachments_on_io_stream_file_name              (io_stream_file_name)
#

