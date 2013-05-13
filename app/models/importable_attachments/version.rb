# versions are managed by the paper_trail gem... providing a history of
# instance-deltas
module ImportableAttachments
  class Version < ActiveRecord::Base
    attr_accessible :event, :item_id, :item_type, :object, :object_changes, :whodunnit

    include SmarterDates if ::Configuration.for('smarter_dates').enabled
    include Rails::MarkRequirements if ::Configuration.for('mark_requirements').enabled

    belongs_to :item, polymorphic: true

    # NOTE: to save nested-model forms, new instances must be valid. Therefore,
    #       attachable_id = nil must be valid when attachable is != nil
    #validates :item_id, if: :item_id?, numericality: {only_integer: true, greater_than: 0}
    validates :item_id, alpha_numeric: {punctuation: true}, if: :item_id?

    validates :item_type, alpha_numeric: {punctuation: true}, if: :item_type?

    if ::Configuration.for('versioning').validate_item_type_constants
      validates :item_type, existing_class: true, if: :item_type?
    end

    # :call-seq:
    # object_has? :pattern
    #
    # yields versions in which the object contains a pattern

    scope :object_has?, lambda { |pattern| where('object LIKE ?', "%#{pattern}%") }

    # :call-seq:
    # Klass.in_the_last N
    #
    # yields objects created in the last N (where N is a timestamp)

    scope :in_the_last, lambda { |dt| where('created_at > ?', dt.ago) }

    # :call-seq:
    # yml_to_ruby
    #
    # loads the yaml object into a ruby-hash
    # if this is the 'destroyed' version, then RTFM reify

    def yml_to_ruby
      Psych.load object
    end

  end
end
