# validate field contains the name of an existing class
class ExistingClassValidator < ActiveModel::EachValidator

  # :call-seq:
  # validate_each :record, :attr, :value
  #
  # validates that value is the name of an existing class

  def validate_each(record, attr, value)
    types = value.split(/::/).map(&:to_sym)
    item_type_result = types.inject(Module) do |constant, name|
      constant.const_get(name) if constant && constant.constants.include?(name)
    end
    record.errors[attr] << 'unknown module or class' unless item_type_result.present?
  end

end
