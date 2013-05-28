require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ImportableAttachments::Attachment do
  # :call-seq:
  # mock_io_stream [:opts]
  #
  # yields a mock Paperclip::Attachment object

  def mock_io_stream(opts = {})
    attached_to = opts[:attach_to]
    @io_stream = Paperclip::Attachment.new(:io_stream, attached_to,
      {path: ::Configuration.for('attachments').path,
        preserve_files: true, processors: [:save_upload]})
    spec_dir = File.dirname(@io_stream.path).sub(/(?:\/\.?)?$/, "")
    FileUtils.mkdir_p spec_dir unless File.directory? spec_dir
    @io_stream
  end

  # :call-seq:
  # mock_attachment [:opts]
  #
  # yields a mock Attachment object

  def mock_attachment(opts = {})
    lopts = {id: 27,
      io_stream: nil,
      io_stream_file_name: 'mostly_empty.csv',
      io_stream_content_type: 'Test Content Type',
      io_stream_file_size: 1,
      io_stream_updated_at: DateTime.now,
      revision_number: 1,
      attachable_type: nil, attachable_id: nil, version: 1}
    @attachment = mock_model(ImportableAttachments::Attachment, lopts.merge(opts))
    @attachment.stubs(:io_stream).returns(mock_io_stream(:attach_to => @attachment))
    FileUtils.cp @spec_file, @attachment.io_stream.path
    @attachment
  end

  before :each do
    #ActiveRecord::Base.send(:subclasses).each{|m|m.destroy_all}
    @spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty.csv')

    mock_attachment
    #Attachment.stubs(:find).with(@attachment.id.to_s).returns(@attachment)
  end

  context 'validations' do
    it { should have_valid(:attachable_id).when(nil, 1, 2^64-1) }
    it { should_not have_valid(:attachable_id).when(-1, 1.1) }

    it { should have_valid(:attachable_type).when(nil, 'ImportableAttachments::Attachment') }
    it { should_not have_valid(:attachable_type).when("Test \x0 data") }

    it { should have_valid(:io_stream_file_name).when('Test data') }
    it { should_not have_valid(:io_stream_file_name).when(nil, "Test \x0 data") }

    it { should have_valid(:io_stream_content_type).when('Test data') }
    it { should_not have_valid(:io_stream_content_type).when(nil, "Test \x0 data") }

    it { should have_valid(:io_stream_updated_at).when(nil, Date.today) }
    #it { should_not have_valid(:io_stream_updated_at).when("Test \x0 data") }

    it 'should ensure the attachment exists' do
      should validate_attachment_presence(:io_stream)
    end

    it 'should ensure the attachment is non-empty' do
      should validate_attachment_size(:io_stream).greater_than(0)
    end

    it 'should require an :io_stream_file_name' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.io_stream_file_name = nil
      attachment.should_not be_valid
      attachment.should have(1).error_on(:io_stream_file_name)
    end

    it 'should not allow odd characters in :io_stream_file_name' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.io_stream_file_name = "file_path\b\b\b\b\bpath"
      attachment.should_not be_valid
      attachment.should have(1).error_on(:io_stream_file_name)
    end
  end

  context 'expected behavior:' do
    it 'should provide an :io_stream_content_type' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.should be_valid
    end

    it 'should save the file to the filesystem' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.save!
      File.exist?(attachment.io_stream.path).should be_true
    end

    it 'should identify an unsaved file as nil' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.magic_mime_type.should be_nil
    end

    it 'should identify the file mime_type as CSV' do
      attachment = ImportableAttachments::Attachment.create! :io_stream => File.new(@spec_file, 'rb')
      attachment.magic_mime_type.should == 'text/plain'
      attachment.io_stream.content_type.should == 'text/csv'
    end

    it 'should provide an :io_stream_mime_type' do
      attachment = ImportableAttachments::Attachment.new :io_stream => File.new(@spec_file, 'rb')
      attachment.io_stream_mime_type.should be_a(MIME::Type)
    end

    it 'should save multiple versions of the file to the filesystem' do
      with_versioning do
        spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty.csv')
        attachment1 = ImportableAttachments::Attachment.new :io_stream => File.new(spec_file, 'rb')
        attachment1.save!
        File.exist?(attachment1.io_stream.path).should be_true
        if ::Configuration.for('attachments').include_revision_in_filename
          attachment1.io_stream.path.should match /mostly_empty\.1\.csv$/
        else
          attachment1.io_stream.path.should match /mostly_empty\.csv$/
        end

        #attachment1.io_stream = File.new(@spec_file,'rb')
        ImportableAttachments::Attachment.stubs(:find).with(attachment1.id).returns(attachment1)
        attachment2 = ImportableAttachments::Attachment.find(attachment1.id)
        spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty.csv')
        attachment2.update_attributes :io_stream => File.new(spec_file, 'rb')
        File.exist?(attachment2.io_stream.path).should be_true
        if ::Configuration.for('attachments').include_revision_in_filename
          attachment2.io_stream.path.should match /mostly_empty\.2\.csv$/
        else
          attachment1.io_stream.path.should match /mostly_empty\.csv$/
        end
      end
    end

    it 'should yield a revision_number' do
      with_versioning do
        spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty.csv')
        attachment1 = ImportableAttachments::Attachment.new :io_stream => File.new(spec_file, 'rb')
        attachment1.save!
        attachment1.revision_number.should == 1

        #attachment1.io_stream = File.new(@spec_file,'rb')
        ImportableAttachments::Attachment.stubs(:find).with(attachment1.id).returns(attachment1)
        attachment2 = ImportableAttachments::Attachment.find(attachment1.id)
        spec_file = Rails.root.join('spec', 'attachments', 'mostly_empty_copy.xls')
        attachment2.update_attributes :io_stream => File.new(spec_file, 'rb')
        attachment2.revision_number.should == 2
      end
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

