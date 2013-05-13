require 'activerecord-import/base'

class Book < ActiveRecord::Base
  include SmarterDates if ::Configuration.for('smarter_dates').enabled
  attr_accessible :author, :last_checkout_at, :title, :library_id
  belongs_to :library, :inverse_of => :books

  validates :title, alpha_numeric: {punctuation: :limited}, presence: true
  validates :author, alpha_numeric: {punctuation: :limited}, presence: true
  validates :library_id, presence: true

  RECORD_HEADERS = {title: 'title', author: 'author', last_checkout_at: 'last checkout at'}
end
