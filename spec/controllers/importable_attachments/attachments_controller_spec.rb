require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module ImportableAttachments
  describe AttachmentsController do

    # :call-seq:
    # set_request_environment [:options]
    #
    # sets request headers e.g. X-File-Nmae, content_type, RAW_POST_DATA

    def set_request_environment(opts = {})
      lopts = request_environment_opts opts
      req_env = request.env
      req_env['X-Requested-With'] = 'XMLHttpRequest' if lopts[:xml]
      req_env['content_type'] = lopts[:content_type]
      req_env['X-File-Name'] = File.basename lopts[:spec_file]
      req_env['RAW_POST_DATA'] = File.new(lopts[:spec_file], 'rb')
    end

    # :call-seq:
    # request_environment_opts [:options]
    #
    # sets request headers e.g. X-File-Nmae, content_type, RAW_POST_DATA

    def request_environment_opts(opts = {})
      lopts = {spec_file: @path_to_spec_file, xml: false, content_type: 'application/excel'}
      lopts.merge opts
    end

    # :call-seq:
    # mock_attachment [:opts]
    #
    # yields a mock ImportableAttachments::Attachment object

    def mock_attachment(opts = {})
      lopts = {id: 27,
        io_stream: nil,
        io_stream_file_name: 'zero_length.csv',
        io_stream_content_type: 'Test Content Type',
        io_stream_file_size: 1,
        io_stream_updated_at: DateTime.now,
        revision_number: 1,
        attachable_type: nil, attachable_id: nil, version: 1}
      @attachment = mock_model(ImportableAttachments::Attachment, lopts.merge(opts))
      @attachment.stubs(:io_stream).returns(mock_io_stream(attach_to: @attachment))

      # In the all_controllers_spec case, the file must be copied
      stream_path = @attachment.io_stream.path.to_s
      if @spec_file.path != stream_path
        FileUtils.cp @spec_file, stream_path
      end

      @attachment
    end

    # :call-seq:
    # mock_io_stream [:opts]
    #
    # yields a mock Paperclip::Attachment object

    def mock_io_stream(opts = {})

      @io_stream = Paperclip::Attachment.new(:io_stream, @attachment,
        {path: ':rails_root/public/:rails_env/:style/:attachable_klass/:id_partition/:basename.:stream_version.:extension',
          preserve_files: true, processors: [:save_upload]})
      spec_dir = File.dirname(@io_stream.path).sub(/(?:\/\.?)?$/, "")
      FileUtils.mkdir_p spec_dir unless File.directory? spec_dir
      @io_stream.stubs(:path).returns(@path_to_spec_file)
      @io_stream
    end

    before :each do
      @path_to_spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty_copy.xls').to_s
      @spec_file = File.new(@path_to_spec_file, 'rb')
      @spec_file.stubs(:original_filename).returns(File.basename(@path_to_spec_file))
      @uploaded_file = fixture_file_upload @path_to_spec_file, 'application/excel'

      mock_attachment
    end

    # TODO: restore @path_to_spec_file via Git... to be anal
    after :each do
    end

    context 'GET index' do
      it 'assigns all associated attachments as @attachments' do
        attachments = [@attachment]
        ImportableAttachments::Attachment.stubs(:order).with(:io_stream_updated_at).returns(attachments)
        get :index
        assigns(:attachments).should eq(attachments)
      end
    end

    context 'GET show' do
      it 'should respond with status 200' do
        ImportableAttachments::Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
        path_to = Rails.root.join('spec', 'attachments', @attachment.io_stream_file_name).to_s
        @io_stream.stubs(:path).returns(path_to)
        #@attachment.stubs(:io_stream).returns(@io_stream)
        get :show, id: @attachment.id.to_s
        response.status.should be 200
      end

      it 'assigns the requested attachment as @attachment' do
        ImportableAttachments::Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
        get :show, id: @attachment.id.to_s
        assigns(:attachment).should eq(@attachment)
      end
    end

    context 'GET download' do
      it 'should send the requested attachment as a file' do
        set_request_environment spec_file: @path_to_spec_file
        ImportableAttachments::Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
        @attachment.stubs(:io_stream_file_name).returns(File.basename(@path_to_spec_file))
        get :download, id: @attachment.id.to_s
        response.headers['Content-Disposition'].should == "attachment; filename=\"mostly_empty_copy.xls\""
      end
    end

    context 'GET new' do
      it 'assigns a new attachment as @attachment' do
        get :new
        assigns(:attachment).should be_a_new(ImportableAttachments::Attachment)
      end
    end

    context 'GET edit' do
      it 'assigns the requested attachment as @attachment' do
        ImportableAttachments::Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
        get :edit, id: @attachment.id.to_s
        assigns(:attachment).should eq(@attachment)
      end
    end

    context 'POST create' do
      context 'with valid params' do
        it 'creates a new ImportableAttachments::Attachment' do
          set_request_environment
          expect {
            post :create, attachment: {io_stream: @uploaded_file}
          }.to change(ImportableAttachments::Attachment, :count).by(1)
        end

        it 'assigns a newly created attachment as @attachment' do
          set_request_environment
          post :create, attachment: {io_stream: @uploaded_file}
          assigns(:attachment).should be_a(ImportableAttachments::Attachment)
          assigns(:attachment).should be_persisted
        end

        it 'should capture the original filename' do
          set_request_environment
          post :create, attachment: {io_stream: @uploaded_file}
          assigns(:attachment).io_stream_file_name.should == request.env['X-File-Name']
        end

        it 'should save the file to disk' do
          set_request_environment
          post :create, attachment: {io_stream: @uploaded_file}
          path = assigns(:attachment).io_stream.path
          path.should_not be_blank
          File.exist?(path).should == true
        end
      end

      context 'with invalid params' do
        it 'assigns a newly created but unsaved attachment as @attachment' do
          set_request_environment
          ImportableAttachments::Attachment.any_instance.expects(:save).returns(false)
          lambda {
            post :create, attachment: {io_stream: nil}
          }.should_not change(@attachment, :io_stream)
        end
      end
    end

    context 'PUT update' do
      context 'with valid params' do
        before :each do
          @path_to_spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty.csv').to_s
        end

        it 'updates the requested attachment' do
          set_request_environment
          attachment = ImportableAttachments::Attachment.create! io_stream: fixture_file_upload(@path_to_spec_file, 'text/csv')
          ImportableAttachments::Attachment.stubs(:find).with(attachment.id.to_s).returns(attachment)
          put :update, id: attachment.id.to_s, attachment: {io_stream: @uploaded_file}
          assigns(:attachment).io_stream_file_name.should == @uploaded_file.original_filename
        end

        it 'assigns the requested attachment as @attachment' do
          set_request_environment
          ImportableAttachments::Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
          @attachment.stubs(:update_attributes).with('io_stream' => @uploaded_file).returns(@attachment)
          put :update, id: @attachment.id.to_s, attachment: {io_stream: @uploaded_file}
          assigns(:attachment).should eq(@attachment)
        end

        it 'should create a new version of the file' do
          set_request_environment
          attachment = ImportableAttachments::Attachment.create! io_stream: fixture_file_upload(@path_to_spec_file, 'teext/csv')
          ImportableAttachments::Attachment.stubs(:find).with(attachment.id.to_s).returns(attachment)
          first_path = attachment.io_stream.path
          put :update, id: attachment.id.to_s, attachment: {io_stream: @uploaded_file}
          second_path = assigns(:attachment).io_stream.path
          first_path.should_not == second_path
        end
      end

      context 'with invalid params' do
        it 'does not update the attachment if the file is not found' do
          set_request_environment
          attachment = ImportableAttachments::Attachment.create! io_stream: @uploaded_file
          ImportableAttachments::Attachment.stubs(:find).with(attachment.id.to_s).returns(attachment)
          attachment.stubs(:update_attributes).with('these' => 'params').returns(false)
          lambda {
            put :update, id: attachment.id.to_s, attachment: {'these' => 'params'}
          }.should_not change(attachment, :io_stream)
        end
      end
    end

    context 'DELETE destroy' do
      it 'destroys the requested attachment' do
        attachment = ImportableAttachments::Attachment.create! io_stream: @uploaded_file
        ImportableAttachments::Attachment.stubs(:find).with(attachment.id.to_s).returns(attachment)
        expect {
          delete :destroy, id: attachment.id.to_s
        }.to change(ImportableAttachments::Attachment, :count).by(-1)
      end
    end

  end
end

