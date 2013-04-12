xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.attachments do
  xml.page params[:page]
  xml.total_pages(@filtered_collection ? (@filtered_collection.count / params[:rows].to_f).ceil : 1)
  xml.num_records(@filtered_collection ? @filtered_collection.count : 0)
  xml.rows do
    @attachments && @attachments.each do |u|
      xml.attachment id: u.id do
        xml.id u.id
        xml.parent_type u.parent_type
        xml.parent_id u.parent_id
        xml.revision_number u.revision_number
        xml.io_stream_file_name u.io_stream_file_name
        xml.io_stream_content_type u.io_stream_content_type
        xml.io_stream_file_size u.io_stream_file_size
        xml.io_stream_updated_at u.io_stream_updated_at
        xml.created_at u.created_at
        xml.updated_at u.updated_at
      end
    end
  end
end

