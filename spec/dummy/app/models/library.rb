class Library < ActiveRecord::Base
  include SmarterDates if ::Configuration.for('smarter_dates').enabled

  if ::Configuration.for('versioning').enabled
    has_paper_trail ignore: [:updated_at]
  end

  RECORD_HEADERS = ['title', 'author', 'last checkout at']

  if ::Configuration.for('attachments').enabled
    extend ImportableAttachments::Base::ClassMethods
    has_importable_attachment spreadsheet_columns: RECORD_HEADERS,
      import_into: :books
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

  protected

  def sanitize_data_callback(headers, sheet) # :nodoc:
    new_sheet = sheet.map {|row| row + [id]}
    [headers + ['library_id'], new_sheet]
  end
end
