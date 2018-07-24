require 'rails_helper'

RSpec.describe ProblemsController, type: :controller do

  # https://github.com/rspec/rspec-collection_matchers

  describe '#index' do

    subject(:get_index) { get :index }

    before :each do
      get_index
    end

    it 'should render index template' do
      expect(response).to render_template('index')
    end

    it 'should assing @problems variable' do
      expect(assigns(:problems)).not_to be_nil
    end

  end

  describe '#new' do

    let!(:user_sud) { create(:user) }

    subject(:get_new)  { get :new }

    context 'logged in user' do
      before :each do
        user_sud.confirm
        sign_in(user_sud)
        get_new
      end

      it 'should render new template' do
        expect(response).to render_template('new')
      end

      it 'should assign @problem' do
        expect(assigns(:problem)).not_to be_nil
      end

      it 'should assign @all_users_mapped' do
        expect(assigns(:all_users_mapped)).not_to be_nil
        expect(assigns(:all_users_mapped)).to include([ user_sud.full_name, user_sud.id])
      end

    end

      it 'not logged in user should be redirected to log_in' do
      get_new
      redirect_to :sign_in
    end
  end

  describe '#create' do

    let!(:user_sud) { create(:user) }
    let(:valid_attributes) {  { problem: attributes_for(:problem) } }
    let(:invalid_attributes) {  { problem: attributes_for(:problem, title: nil) } }

    subject(:valid_post)  { post :create, params: valid_attributes }
    subject(:invalid_post) { post :create, params: invalid_attributes }

    context 'logged in user' do

      before :each do
        user_sud.confirm
        sign_in(user_sud)
      end

      it 'shoudl create problem with valid attributes' do
        expect { valid_post }.to change { Problem.count }.by(1)
      end

      it 'should not create problem with not valid attributes' do
        expect { invalid_post }.to change { Problem.count }.by(0)
      end

      it 'should assign proper variables' do
        valid_post
        expect(assigns(:problem)).not_to be_nil
        expect(assigns(:all_users_mapped)).not_to be_nil
        expect(assigns(:all_users_mapped)).to include([ user_sud.full_name, user_sud.id])
      end

      it 'should redirect to root with notice when valid post' do
        valid_post
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be_present
      end

      it 'should re-render new view with not valid post' do
        invalid_post
        expect(response).to render_template('new')
      end

      # ???
      # it 'should create problem without tags with valid attributes' do
      # end

      # it 'should create problem without contributors with valid attributes' do
      # end

      # it 'should create problem without tags and contributors with valid attributes' do
      # end
    end

    it 'not logged user should be restricted from creating problem' do
      valid_post
      redirect_to :sign_in
    end
  end


  describe '#add_contributor' do


      context 'logged in user' do

      end

  end

    # describe 'problem creating' do

    #     let!(:user_sud) { create(:user) }

    #     context 'restrictions' do
    #         it 'not logged user should be restricted from creating new problems' do
    #             get :new_logged_user
    #             expect(response).to redirect_to(new_user_session_path)
    #         end

    #         it 'logged in user should be able to create new post' do
    #             user_sud.confirm
    #             sign_in(user_sud)
    #             get :new_logged_user
    #             expect(response).to render_template('new_logged_user')
    #         end

    #         it 'should assign variables' do
    #             user_sud.confirm
    #             sign_in(user_sud)
    #             get :new_logged_user
    #             expect(assigns(:problem)).not_to be_nil
    #             expect(assigns(:all_users_mapped)).not_to be_nil
    #         end
    #     end

    #     context 'problem creation for logged user' do
    #         let(:valid_attributes) {  { problem: attributes_for(:problem) } }
    #         let(:invalid_attributes) {  { problem: attributes_for(:problem, title: nil) } }

    #         subject(:valid_post)	{ post :create,	params:	valid_attributes }
    #         subject(:invalid_post) { post :create, params: invalid_attributes }

    #         before :each do
    #             user_sud.confirm
    #             sign_in(user_sud)
    #         end

    #         it 'should create problem with valid attributes' do
    #             expect { valid_post }.to change { Problem.count }.by(1)
    #         end

    #         it 'should not create problem with invalid attributes' do
    #             expect { invalid_post }.to change { Problem.count }.by(0)
    #         end

    #         it 'should flash notice after creation with valid attributes' do
    #             valid_post
    #             expect(flash[:notice]).to be_present
    #         end

    #         it 'should redirect to root_path creation with valid attributes' do
    #             valid_post
    #             expect(response).to redirect_to(root_path)
    #         end

    #         it 'should render new_logged_user template when not valid post' do
    #             invalid_post
    #             expect(response).to render_template('new_logged_user')
    #         end

    #         it 'should assign users_mapped' do
    #             valid_post
    #             expect(assigns(:all_users_mapped)).not_to be_nil
    #         end

    #         it 'should create tags associated with problem' do
    #             pending "implement #{__FILE__}"
    #         end

    #         it 'should create users associated with problem' do
    #             pending "implement #{__FILE__}"
    #         end

    #         it 'should create both users and tags associated with problem' do
    #             pending "implement #{__FILE__}"
    #         end

    #     end
    # end

    # # whole action for simplicity is tested using capybara
    # describe '#add_contributor' do
    #     let!(:user_one) { create(:user_1) }
    #     let!(:user_two) { create(:user) }

    #     it 'should assign users_mapped' do
    #         get :add_contributor, xhr: true
    #         expect(assigns(:all_users_mapped)).to match_array([ [user_one.full_name, user_one.id],
    #         [user_two.full_name, user_two.id] ])
    #     end
    # end

    # describe '#show' do
    #     let(:problem_sud) { create(:problem) }
    #     let(:problem_sud2) { create(:problem_2) }
    #     let(:comment_one) { create(:comment) }
    #     let(:comment_two) { create(:comment_1) }

    #     before(:each) do
    #         get :show, params: { id: problem_sud.id }
    #     end

    #     it 'should redner proper template' do
    #         expect(response).to render_template('show')
    #     end

    #     it 'comments variable should not be nil when comments present' do
    #         pending "implement #{__FILE__}"
    #     end

    #     it 'comments variable should be nil when comments are not present' do
    #         pending "implement #{__FILE__}"
    #     end

    # end

    # describe '#search_problems' do
    #     let(:problem_included) { create(:problem, title: 'Hello') }
    #     let(:problem_excluded) { create(:problem, title: 'Bye bye')}

    #     it 'should return proper data' do
    #         get :search_problems, params: { lookup: 'Hello' }

    #         expect(assigns(:problems)).to match_array([ problem_included ])
    #     end

    #     it 'should not return not proper data' do
    #         get :search_problems, params: { lookup: 'Hello' }

    #         expect(assigns(:problems)).not_to match_array([ problem_excluded ])
    #     end

    #     it 'when query blank should redirect to root with alert' do
    #         get :search_problems, params: { lookup: nil }

    #         expect(flash[:alert]).to be_present
    #         expect(response).to redirect_to(root_path)
    #     end

    # end
    # VERY INTERESTING COMMENT
    # describe '#index' do
    #     let(:problem_one) { create(:problem) }
    #     let(:problem_two) { create(:problme) }

    #     before(:each) do
    #         get :index
    #     end

    #     it { should respond_with(200..300) }
    #     it { should render_template('index') }

    #     it 'should return all problems' do
    #         expect(assigns(:problems)).to match_array( [problem_one, problem_two] )
    #     end
    # end

end
