require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

module ImportableAttachments
  describe VersionsController do

    after :each do
      Version.destroy_all
    end

    before :each do
      @routes = Engine.routes
      Version.destroy_all
    end

    # This should return the minimal set of attributes required to create a valid
    # Version. As you add validations to Version, be sure to
    # update the return value of this method accordingly.
    def valid_attributes
      { item_type: 'Attachment', item_id: 27, event: 'update' }
    end

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # VersionsController. Be sure to keep this updated too.
    def valid_session
      {}
    end

    context "GET index" do
      it "assigns all versions as @versions" do
        version = Version.create! valid_attributes
        get :index, {}, valid_session
        assigns(:versions).should eq([version])
      end
    end

    context "GET show" do
      it "assigns the requested version as @version" do
        version = Version.create! valid_attributes
        get :show, {:id => version.to_param}, valid_session
        assigns(:version).should eq(version)
      end
    end

    context "GET new" do
      it "assigns a new version as @version" do
        get :new, {}, valid_session
        assigns(:version).should be_a_new(Version)
      end
    end

    context "GET edit" do
      it "assigns the requested version as @version" do
        version = Version.create! valid_attributes
        get :edit, {:id => version.to_param}, valid_session
        assigns(:version).should eq(version)
      end
    end

    context "POST create" do
      context "with valid params" do
        it "creates a new Version" do
          expect {
            post :create, {:version => valid_attributes}, valid_session
          }.to change(Version, :count).by(1)
        end

        it "assigns a newly created version as @version" do
          post :create, {:version => valid_attributes}, valid_session
          assigns(:version).should be_a(Version)
          assigns(:version).should be_persisted
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved version as @version" do
          # Trigger the behavior that occurs when invalid params are submitted
          Version.any_instance.stub(:save).and_return(false)
          post :create, {:version => { "item_type" => "invalid value" }}, valid_session
          assigns(:version).should be_a_new(Version)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Version.any_instance.stub(:save).and_return(false)
          post :create, {:version => { "item_type" => "invalid value" }}, valid_session
          response.should render_template("new")
        end
      end
    end

    context "PUT update" do
      context "with valid params" do
        it "updates the requested version" do
          version = Version.create! valid_attributes
          # Assuming there are no other versions in the database, this
          # specifies that the Version created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Version.any_instance.should_receive(:update_attributes).with({ "item_type" => "MyString" })
          put :update, {:id => version.to_param, :version => { "item_type" => "MyString" }}, valid_session
        end

        it "assigns the requested version as @version" do
          version = Version.create! valid_attributes
          put :update, {:id => version.to_param, :version => valid_attributes}, valid_session
          assigns(:version).should eq(version)
        end
      end

      context "with invalid params" do
        it "assigns the version as @version" do
          version = Version.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Version.any_instance.stub(:save).and_return(false)
          put :update, {:id => version.to_param, :version => { "item_type" => "invalid value" }}, valid_session
          assigns(:version).should eq(version)
        end

        it "re-renders the 'edit' template" do
          version = Version.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Version.any_instance.stub(:save).and_return(false)
          put :update, {:id => version.to_param, :version => { "item_type" => "invalid value" }}, valid_session
          response.should render_template("edit")
        end
      end
    end

    context "DELETE destroy" do
      it "destroys the requested version" do
        version = Version.create! valid_attributes
        expect {
          delete :destroy, {:id => version.to_param}, valid_session
        }.to change(Version, :count).by(-1)
      end
    end

  end
end
