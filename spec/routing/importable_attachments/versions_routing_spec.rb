require 'spec_helper'

module ImportableAttachments
  describe VersionsController do
    context 'routing' do

      before :each do
        @routes = ::ImportableAttachments::Engine.routes

        # https://github.com/rspec/rspec-rails/pull/539
        assertion_instance.instance_variable_set(:@routes, ::ImportableAttachments::Engine.routes)
      end

      it 'routes to #index' do
        get('/versions').should route_to('importable_attachments/versions#index')
      end

      it 'routes to #new' do
        get('/versions/new').should route_to('importable_attachments/versions#new')
      end

      it 'routes to #show' do
        get('/versions/1').should route_to('importable_attachments/versions#show', :id => '1')
      end

      it 'routes to #edit' do
        get('/versions/1/edit').should route_to('importable_attachments/versions#edit', :id => '1')
      end

      it 'routes to #create' do
        post('/versions').should route_to('importable_attachments/versions#create')
      end

      it 'routes to #update' do
        put('/versions/1').should route_to('importable_attachments/versions#update', :id => '1')
      end

      it 'routes to #destroy' do
        delete('/versions/1').should route_to('importable_attachments/versions#destroy', :id => '1')
      end
    end
  end
end
