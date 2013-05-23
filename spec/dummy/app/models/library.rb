require 'importable_attachments/importers'

class Library < ActiveRecord::Base
  include SmarterDates if ::Configuration.for('smarter_dates').enabled

  if ::Configuration.for('versioning').enabled
    has_paper_trail ignore: [:updated_at]
  end

  def attachment=(params)
    super params
    import_attachment if attachment && attachment.valid?
  end

  RECORD_HEADERS = ['title', 'author', 'last checkout at']

  if ::Configuration.for('attachments').enabled
    extend ImportableAttachments::Base::ClassMethods
    has_importable_attachment spreadsheet_columns: RECORD_HEADERS,
      import_into: :books
    include ImportableAttachments::Importers::Csv
    validates_with ImportableAttachments::CsvValidator, if: Proc.new { |model| model.attachment.present? && model.attachment.persisted? }
  end

  # --------------------------------------------------------------------------
  # define: attributes and relationships
  has_many :books, dependent: :destroy, inverse_of: :library

  attr_accessor :converted_headers

  # --------------------------------------------------------------------------
  # define: DTD i.e. validations
  validates :name, alpha_numeric: {punctuation: :limited}, presence: true
  validates :address, alpha_numeric: {punctuation: :limited}, presence: true

  # --------------------------------------------------------------------------
  # define: scopes
  attr_accessible :name, :address

  # --------------------------------------------------------------------------
  # define: behaviors

  # : call-seq:
  # import_attachment
  #
  # imports an attachment of a given mime-type (data-stream to ruby),
  # calls import_rows with a ruby data-store

  def import_attachment
    import_csv
  end

  protected

  def sanitize_data_callback(headers, sheet) # :nodoc:
    new_sheet = sheet.map {|row| row + [id]}
    [headers + ['library_id'], new_sheet]
  end
end
