require 'rails_helper'


RSpec.describe ProblemsController, type: :controller do

  # https://github.com/rspec/rspec-collection_matchers

  subject(:root_alert_redirect) do
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to be_present
  end

  subject(:root_notice_redirect) do
    expect(response).to redirect_to(root_path)
    expect(flash[:notice]).to be_present
  end

  subject(:authentication_redirect) { expect(response).to redirect_to(new_user_session_path) }

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

  # ------------------------------------------------------------------------

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
      end

    end

      it 'not logged in user should be redirected to log_in' do
      get_new
      authentication_redirect
    end
  end

  # ------------------------------------------------------------------------

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

      it 'should create problem with valid attributes' do
        expect { valid_post }.to change { Problem.count }.by(1)
      end

      it 'should not create problem with not valid attributes' do
        expect { invalid_post }.to change { Problem.count }.by(0)
      end

      it 'should assign proper variables' do
        valid_post
        expect(assigns(:problem)).not_to be_nil
        expect(assigns(:all_users_mapped)).not_to be_nil
      end

      it 'should redirect to root with notice when valid post' do
        valid_post
        root_notice_redirect
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
     # expect(response).to redirect_to(new_user_session_path)
     authentication_redirect
    end
  end

  # ------------------------------------------------------------------------

  describe '#add_contributor' do

    let!(:user_sud) { create(:user) }
    subject(:get_contributors)  { get :add_contributor }

      context 'logged in user' do

        before :each do
          user_sud.confirm
          sign_in(user_sud)
        end

        it 'should not have html template' do
          expect { get_contributors }.to raise_exception(ActionController::UnknownFormat)
        end

        it 'should assign @all_users_mapped' do
          begin
            get_contributors
          rescue
            expect(assigns(:all_users_mapped)).not_to be_nil
          end
        end
      end

      it 'not logged in should be restricted' do
        get_contributors
       # expect(response).to redirect_to(new_user_session_path)
       authentication_redirect
      end
  end

  describe '#destroy' do
    let!(:user_sud) { create(:user) }
    let!(:problem_sud) { create(:problem) }

    subject(:delete_problem) { delete :destroy, params: { id: problem_sud.id } }

    context 'logged in' do

      before :each do
        user_sud.confirm
        sign_in(user_sud)
      end

      it 'should be able to destroy' do
        expect{ delete_problem }.to change(Problem, :count).by(-1)
      end

      context 'behavipour after destroy' do
        before(:each) { delete_problem }

        it 'should redirect to root_path with alert after destroy' do
          root_alert_redirect
        end

        it 'should assign @destroy variable' do
          expect(assigns(:problem)).not_to be_nil
        end
      end
    end

    it 'not logged in user should be restricted from destroying' do
      expect { delete_problem }.to change(Problem, :count).by(0)
      #expect(response).to redirect_to(new_user_session_path)
      authentication_redirect
    end
  end

  # ------------------------------------------------------------------------

  describe '#show' do

    let!(:problem_sud) { create(:problem) }

    subject(:show_problem) { get :show, params: { id: problem_sud.id  } }

    before(:each) { show_problem }

    context 'logged in' do
      let!(:user_sud) { create(:user) }

      before :each do
        user_sud.confirm
        sign_in(user_sud)
      end

      it 'should see specific problem' do
        expect(response).to render_template(:show)
      end
    end

    it 'not logged uswer should see specific problem' do
      expect(response).to render_template(:show)
    end

    it 'should assign all ne cessary variables' do
      expect(assigns(:problem)).not_to be_nil
      expect(assigns(:comment)).not_to be_nil
      expect(assigns(:is_current_contributor)).not_to be_nil
      expect(assigns(:is_creator)).not_to be_nil
      expect(assigns(:comments)).not_to be_nil
      expect(assigns(:users)).not_to be_nil
      expect(assigns(:comment_errors)).not_to be_nil
    end
  end

  # ------------------------------------------------------------------------

  describe 'Searching logic' do

      context 'user-related behaviour' do
        let(:user_sud) { create(:user) }
        let(:problem_sud) { create(:problem) }
        let!(:problem_two) { create(:problem_2) }
        subject(:general_search) { get :search_problems, params: { lookup: problem_sud.title } }

        it 'guest should be able to search' do
            general_search
            expect(response).to render_template('search_problems')
            expect(assigns(:problems).count).to eq(1)
        end

        it 'logged in user should be able to search' do
          user_sud.confirm
          sign_in(user_sud)
          general_search
          expect(response).to render_template('search_problems')
          # to even more guarantee proper results -> had many problems
          # while refactoring etc
          expect(assigns(:problems).count).to eq(1)
        end
      end

      context 'basic search' do
        let(:problem_one) { create(:problem) }
        let(:problem_two) { create(:problem_2) }

        # Almost the same as some tests above - on purspose
        it 'should search using title with proper result' do
          get :search_problems, params: { lookup: problem_one.title }
          expect(assigns(:problems)).to contain_exactly(problem_one)
        end
        # NOTE: default_scope was tested in model?
        it 'should search using content with proper result' do
          get :search_problems, params: { lookup: problem_one.content }
          expect(assigns(:problems)).to contain_exactly(problem_one)
        end

        # in progress
        # it 'should search using references' do
        # end

        it 'should redirect to root_path with alert when query blank' do
          get :search_problems, params: { lookup: "" }
          root_alert_redirect
        end

      end

      context 'advanced search' do
        let(:problem_one) { create(:problem) }
        let(:problem_two) { create(:problem_2) }
        let(:sample_tag_a) { create(:tag) }

        context 'advanced title and content searching' do

          it 'title blank query redirect to root_path with alert' do
            get :search_problems, params: { advanced_search_on: 'on', title_on: 'on', lookup: '' }
            root_alert_redirect
          end

          it 'content blank query redirect to root_path with alert' do
            get :search_problems, params: { advanced_search_on: 'on', content_on: 'on', lookup: '' }
            root_alert_redirect
          end

          it 'title gives valid results' do
            get :search_problems, params: { advanced_search_on: 'on', title_on: 'on', lookup: problem_one.title }
            expect(assigns(:problems)).to contain_exactly(problem_one)
          end

          it 'content gives valid results' do
            get :search_problems, params: { advanced_search_on: 'on', content_on: 'on', lookup: problem_one.content }
            expect(assigns(:problems)).to contain_exactly(problem_one)
          end

          it 'reference_list gives valid results' do
            get :search_problems, params: { advanced_search_on: 'on', lookup: problem_one.reference_list, reference_on: 'on' }
            expect(assigns(:problems)).to contain_exactly(problem_one)
          end
        end


        context 'advanced tag filtering' do
          let(:sample_tag_b) { create(:tag_1) }

          it 'query blank no redirection' do
            get :search_problems, params: { advanced_search_on: 'on', tag_names: ['Ruby on Rails'], lookup: '' }
            expect(response).not_to redirect_to(root_path)
          end


          it 'gives valid results' do
            problem_one.tags << sample_tag_a
            problem_one.tags << sample_tag_b
            problem_two.tags << sample_tag_a

            get :search_problems,
              params: {
              advanced_search_on: 'on',
              tag_names: [ sample_tag_a.name, sample_tag_b.name],
              lookup: 'a'
            }

            expect(assigns(:problems)).to contain_exactly(problem_one)
          end

          it 'should return all problems when no criteria specified' do
            get :search_problems, params: { advanced_search_on: 'on', lookup: ''}
            # laziness
            problem_one.title
            problem_two.title
            expect(assigns(:problems)).to contain_exactly(problem_one, problem_two)
          end

        end

        # ignore advanced options when advanced_search_on not on
        context 'ignore advanced options search when not explicitly on' do
          # override
          let(:problem_one) { create(:problem) }
          let(:problem_two) { create(:problem_2, content: problem_one.title) }

          it 'should use default search' do

          get :search_problems, params: {
            title_on: 'on',
            content_on: 'on',
            tag_names: [sample_tag_a.name],
            lookup: problem_one.title
          }
          # or is between
          expect(assigns(:problems)).to contain_exactly(problem_one, problem_two)
          end
        end
      end

      it 'create_searching_service should produce SearchingService' do
        service = controller.send(:create_searching_service)
        expect(service).not_to be_nil
        expect(service.instance_of? SearchingService).to be true
      end
  end

  # ------------------------------------------------------------------------

  describe 'Filtering logic' do
    let!(:problem_a) { create(:problem, title: 'Android') }
    let!(:problem_b) { create(:problem, title: 'Android problem') }
    let!(:problem_c) { create(:problem, title: 'problem Android problem') }

    it 'should filter descending title' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'title: :desc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('title DESC')).to_a)
    end

    it 'should filter ascedning title' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'title: :asc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('title ASC')).to_a)
    end

    it 'should filter using ascedning updated_at' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'updated_at: :asc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('updated_at ASC')).to_a)
    end

    it 'should filter using descending updated_at' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'updated_at: :desc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('updated_at DESC')).to_a)
    end

    it 'should filter using ascedning content' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'content: :asc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('content ASC')).to_a)
    end

    it 'should filter using descending reference_list' do
      get :filter_search_results, params: {
        lookup: 'Android',
        order_by: 'content: :desc'
      }
      expect(assigns[:problems].to_a).to eq(Problem.order(Arel.sql('content DESC')).to_a)
    end


    # it 'create_filtering_service should produce FilteringService' do
    #   filtering = controller.send(:create_filtering_service, [problem_a])
    #   expect(filtering).not_to be_nil
    #   expect(filtering.instance_of? FilteringService).to be true
    # end
  end

  # ------------------------------------------------------------------------

  describe '#edit' do

  let(:problem_one) { create(:problem) }
  subject(:get_edit) { get :edit, params: { id: problem_one.id } }

  context 'not logged user' do

    it 'should be restricted' do
      get_edit
      authentication_redirect
    end

  end

  context 'logged in user' do

    let(:user_sud) { create(:user) }
    let(:problem_creator) { create(:problem, creator_id: user_sud.id) }

    before :each do
      user_sud.confirm
      sign_in(user_sud)
    end


    it 'not creator or admin can\'t edit' do
      get_edit
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to be_present
    end

    it 'creator can edit' do
      get :edit, params: { id: problem_creator.id }
      expect(response).to render_template('edit')
    end

    it 'should assign @problem and @all_user_mapped' do
      get :edit, params: { id: problem_creator.id }
      expect(assigns(:problem)).not_to be_nil
      expect(assigns(:all_users_mapped)).not_to be_nil
    end
  end

  context 'admin' do
    let(:user_admin) { create(:user, is_admin: true) }

    it 'admin can edit' do
      user_admin.confirm
      sign_in(user_admin)
      get_edit
      expect(response).to render_template('edit')
    end
  end

  end

  # ------------------------------------------------------------------------
  # needs some refactoring
  describe '#update' do
  let(:user_sud) { create(:user) }
  let(:problem_one) { create(:problem_2) }
  let(:problem_two) { create(:problem) }
  let(:valid_attributes) { { id: problem_one.id, problem: attributes_for(:problem, title: 'Valid name') } }
  let(:invalid_attributes) { { id: problem_one.id, problem: attributes_for(:problem, title: nil) } }

  subject(:valid_patch)  { patch :update, params: valid_attributes  }
  subject(:invalid_patch) { patch :update, params: invalid_attributes }

    it 'not logged in user should be restricted' do
      valid_patch
      authentication_redirect
    end

    context 'logged in user' do

      before :each do
        user_sud.confirm
        sign_in(user_sud)
      end

      it 'invalid attributes should re-render template' do
        invalid_patch
        expect(response).to render_template('edit')
      end

      it 'should assign proper variables' do
        valid_patch
        expect(assigns(:problem)).not_to be_nil
      end

      it 'valid update should change attributes' do
        valid_patch
        expect(problem_one.reload.title).to eq('Valid name')
      end

      it 'valid update' do
        valid_patch

        expect(response).to redirect_to(problems_url)
        expect(flash[:notice]).to be_present
      end
    end


  end
end
