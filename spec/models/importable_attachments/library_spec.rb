require 'spec_helper'

def spec_file(file_name)
  Rails.root.join('spec', 'attachments', file_name)
end

describe Library do
  before :each do
    @spec_file = spec_file('books.csv')
  end

  context 'attachment validations' do
    subject { Library.create(name: 'XYZ Library', address: '123 Main St.') }
    it { subject.should have_valid(:attachment).when(nil, Attachment.new(io_stream: File.new(@spec_file))) }
    it {
      subject.should_not have_valid(:attachment).when(Attachment.new io_stream: File.new(Rails.root.join('spec', 'attachments', 'books.txt'))) }
  end

  context 'importing attachments' do
    before :each do
      @attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
    end

    subject { Library.create(name: 'XYZ Library', address: '123 Main St.') }

    context 'in the right format' do
      it 'should optionally allow an attachment' do
        subject.attachment = @attachment
        subject.attachment.should_not be_nil
        subject.attachment.attachable_type.should == 'Library'
        subject.attachment.io_stream_file_name.should == File.basename(@spec_file)
      end

      it 'should import a spreadsheet if it is in the right format' do
        subject.books.should be_empty
        lambda {
          subject.attachment = @attachment
        }.should change(subject.books, :count)
      end
    end

    context 'wrong extension' do
      before :each do
        @spec_file = spec_file('books.txt')
      end

      it 'should not import a spreadsheet if it has the wrong extension' do
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        subject.attachment = attachment
        subject.should_not be_valid
      end

      it 'should not delete existing data if new upload has the wrong extension' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.books, :count)
      end

      it 'should not register / acknowledge the file is still in the system' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.attachment, :io_stream_file_name)
      end
    end

    context 'invalid headers' do
      before :each do
        @spec_file = spec_file('invalid_headers.csv')
      end

      it 'should not import a spreadsheet if it has invalid headers' do
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        subject.attachment = attachment
        subject.should_not be_valid
      end

      it 'should not delete existing data if new upload has invalid headers' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.books, :count)
      end

      it 'should not register / acknowledge the file is still in the system' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.attachment, :io_stream_file_name)
      end
    end

    context 'failed instances' do
      before :each do
        @spec_file = spec_file('failed_instances.csv')
      end

      it 'should not import a spreadsheet if it has failed instances' do
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        subject.attachment = attachment
        subject.should_not be_valid
      end

      it 'should not delete existing data if new upload has failed instances' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.books, :count)
      end

      it 'should not register / acknowledge the file is still in the system' do
        subject.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          subject.attachment = attachment
        }.should_not change(subject.attachment, :io_stream_file_name)
      end
    end
  end

end

