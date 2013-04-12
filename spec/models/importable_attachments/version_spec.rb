require 'spec_helper'

describe ImportableAttachments::Version do
  # :call-seq:
  # mock_version [:opts]
  #
  # yields a mock Version object

  def mock_version(opts = {})
    lopts = {:id => 27, :item_type => nil, :item_id => nil}
    @version = mock_model(Version, lopts.merge(opts))
    @version
  end

  before :each do
    mock_version
  end

  context 'validations' do
    it { should have_valid(:item_id).when(nil, 1, 'uniqueId', 'unique_id', 'unique.id') }

    it { should have_valid(:item_type).when(nil, 'Attachment', 'ImportableAttachments::Attachment') }
    it { should_not have_valid(:item_type).when("Test \x0 data") }
  end
end
