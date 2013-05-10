require 'spec_helper'

describe Library do
  before :each do
    @spec_file = Rails.root.join('spec', 'attachments', 'mini.csv')
  end

  context 'attachment validations' do
    subject { Library.create(name: 'XYZ Library', address: '123 Main St.') }
    it { subject.should have_valid(:attachment).when(nil, Attachment.new(io_stream: File.new(@spec_file))) }
    it {
      subject.should_not have_valid(:attachment).when(Attachment.new io_stream: File.new(Rails.root.join('spec', 'attachments', 'hello.txt'))) }
  end

  context 'importing attachments' do
    before :each do
      @library = Library.create(name: 'XYZ Library', address: '123 Main St.')
      @attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
    end

    after :each do
      @library.destroy
    end

    context 'in the right format' do
      it 'should optionally allow an attachment' do
        @library.attachment = @attachment
        @library.attachment.should_not be_nil
        @library.attachment.attachable_type.should == 'Library'
        @library.attachment.io_stream_file_name.should == File.basename(@spec_file)
      end

      it 'should import a spreadsheet if it is in the right format' do
        @library.books.should be_empty
        lambda {
          @library.attachment = @attachment
        }.should change(@library.books, :count)
      end
    end

    context 'in the wrong format' do
      before :each do
        @spec_file = Rails.root.join('spec', 'attachments', 'hello.txt')
      end

      it 'should not import a spreadsheet if it is in the wrong format' do
        @library.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          @library.attachment = attachment
        }.should_not change(@library.books, :count)
      end

      it 'should not register / acknowledge the file is still in the system' do
        @library.attachment = @attachment
        attachment = Attachment.new io_stream: File.new(@spec_file, 'rb')
        lambda {
          @library.attachment = attachment
        }.should_not change(@library.attachment, :io_stream_file_name)
      end
    end
  end

end

# == Schema Information
#
# Table name: people
#
#  id               :integer(4)      not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  last_name        :string(255)     not null
#  first_name       :string(255)     not null
#  middle_name      :string(255)
#  uses_middle_name :boolean(1)      default(FALSE)
#  can_sponsor      :boolean(1)      default(FALSE)
#  sponsor          :string(255)
#  human_subjects   :string(255)
#  application      :string(255)
#  institution      :string(255)
#  building         :string(255)
#  room             :string(255)
#  phone_number     :string(255)
#
# Indexes
#
#  index_people_on_last_name_and_first_name  (last_name,first_name)
#

