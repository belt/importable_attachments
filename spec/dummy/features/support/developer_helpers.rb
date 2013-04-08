module DeveloperHelpers
  # :call-seq:
  # pretty_response_body
  #
  # displays the response body on multiple, indexed, lines

  def pretty_response_body
    pretty_body = response.body.split(/\n/)
    pretty_body.each_with_index { |line, idx| line.gsub("\t", "  ").gsub!(/^/, "#{idx+1}: ") }
  end

  # :call-seq:
  # pretty_page_html
  #
  # displays the response body on multiple, indexed, lines

  def pretty_page_html
    page.html.split(/\n/).each { |line, idx| line.gsub("\t", "  ") }
  end

  # :call-seq:
  # safe_attributes :object
  #
  # yields an array of accessible attributes...
  # ... without *_ids relations
  # ... with foo_id AND without foo

  def safe_attrs(obj)
    accessible_attrs = obj._accessible_attributes[:default].to_a
    relation_attrs = accessible_attrs.select { |obj| obj.match(/_(?:ids|attributes)$/) }
    accessible_attrs -= relation_attrs
    id_attrs = accessible_attrs.select { |obj| obj.match(/_id$/) }
    accessible_attrs -= id_attrs.map { |obj| obj.sub(/_id$/, "") }
  end

  # :call-seq:
  # post_safe_attrs :object
  #
  # yields the object-as-a-hash of accessible keys => values

  def post_safe_attrs(obj)
    safe_attrs(serialized_obj).inject({}) { |res, obj|
      val = serialized_obj.send(obj); val.is_a?(Array) ? res : res.merge({obj => val}) }
  end
end
World(DeveloperHelpers)

