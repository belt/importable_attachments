# This controller uses Representational State Transfer (REST) principles
# http://en.wikipedia.org/wiki/REST
module ImportableAttachments
  class AttachmentsController < ApplicationController
    respond_to :html, :json
    before_filter :find_parent_by_id, :only => [:show, :edit, :update, :destroy, :download]
    before_filter :find_all_parents, :only => [:index]
    before_filter :generate_parent, :only => [:new]
    before_filter :set_headers, :only => [:show]
    before_filter :respond_with_instance, :only => [:new, :show, :edit]

    # GET /attachments
    def index
      respond_with @attachments
    end

    # GET /attachments/new
    def new
    end

    # GET /attachments/:id
    def show
    end

    def download
      send_data(File.read(stream_path), send_file_options)
    end

    # GET /attachments/:id/edit
    def edit
    end

    # To debug:
    # require 'mechanize'
    # attachment = Attachment.first
    # file_name = 'to_import.xls'
    # spec_file = Rails.root.join('spec', 'attachments', file_name)
    # post_path = "/attachments/:id"
    # get_from  = "/attachments"
    #
    # post_path.sub!(/:id/,file_name)
    # post_to  = URI.parse("http://localhost/#{post_path}")
    #
    # page_form = 'new_attachment_form'
    # page_field = 'attachment[foo]'
    #
    # agent    = Mechanize.new
    # page     = agent.get("http://localhost/#{get_path.sub(/^\//,'')}")
    # form     = page.form(page_form)
    # form.file_upload(:name => page_field).file_name = spec_file
    # result = agent.submit(form)

    # POST /attachments/:id
    def create
      @attachment = Attachment.new params[:attachment]
      if @attachment.save
        redirect_to attachments_path, :notice => 'Successfully created attachment.'
      else
        render :new
      end
    end

    # PUT /attachments/:id
    def update
      if @attachment.update_attributes params[:attachment]
        redirect_to attachments_path, :notice => 'Successfully updated attachment.'
      else
        render :edit
      end
    end

    # DELETE /attachment/:id
    def destroy
      @attachment.destroy
      redirect_to attachments_path, :notice => 'Successfully destroyed attachment.'
    end

    protected

    # :call-seq:
    # find_parent_by_id :id
    #
    # yields an attachment by its :id

    def find_parent_by_id
      @attachment = Attachment.find(params[:id])
    end

    # :call-seq:
    # find_all_parents
    #
    # yields attachments ordered by :io_stream_updated_at

    def find_all_parents
      @attachments = Attachment.order(:io_stream_updated_at)
    end

    # :call-seq:
    # generate_parent
    #
    # yields a new attachment

    def generate_parent
      @attachment = Attachment.new
    end

    # :call-seq:
    # respond_with_instance
    #
    # responds_with :attachment

    def respond_with_instance
      respond_with @attachment
    end

    # :call-seq:
    # stream_path
    #
    # yields the file-streams file-system path, including Rails.root

    def stream_path
      @attachment.io_stream.path(params[:style] || :original)
    end

    # :call-seq:
    # set_headers
    #
    # ensure the attachment file exists and is readable

    def set_headers
      not_found = set_not_found_header
      no_bits = set_permission_denied_header
      is_extinct = set_not_exist_header
      return false if not_found || no_bits || is_extinct
      true
    end

    def set_not_found_header
      return unless @attachment.nil?
      logger.info "attachments.id = (#{params[:id]}) not found"
      head(:not_found)
    end

    def set_not_exist_header
      return unless File.exist? stream_path
      logger.info "file not found: #{stream_path}"
      head(:bad_request)
    end

    def set_permission_denied_header
      return unless File.readable? stream_path
      logger.info "permission denied: #{stream_path}"
      head(:forbidden)
    end

    # :call-seq:
    # send_file_options
    #
    # yields options suitable for send_file() e.g. x_sendfile headers

    def send_file_options
      st = stream_path
      opts = {type: MIME::Types.type_for(st).to_s, filename: @attachment.io_stream_file_name}

      case send_file_method
      when :apache then
        opts[:x_sendfile] = true
      when :nginx then
        head(:x_accel_redirect => st.gsub(Rails.root, ""), :content_type => opts[:type])
      else
        true
      end

      opts
    end

    # :call-seq:
    # send_file_method
    #
    # detect apache / nginx
    #
    # TODO: implement me

    def send_file_method
      :default
    end

  end
end

