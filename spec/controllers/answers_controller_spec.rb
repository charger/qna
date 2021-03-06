require 'rails_helper'

describe AnswersController do
  let(:user) { create :user }
  let(:question) { create(:question) }
  let(:answer) { create(:answer, question: question, user: user) }
  let(:anothers_answer) { create(:answer, question: question) }

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:subject) { post :create, question_id: question, answer: attributes_for(:answer), format: :json }

      before { sign_in(user) }

      it 'creates new answer' do
        expect do
          subject
        end.to change(question.answers, :count).by 1
      end

      it 'correctly assigns user' do
        expect do
          subject
        end.to change(user.answers, :count).by 1
      end

      it 'renders show template' do
        subject
        expect(response).to render_template :show
      end

      it_behaves_like 'publishable', %r{^\/questions\/\d+\/answers$}
    end

    context 'with invalid attributes' do
      before { sign_in(user) }

      it 'does not create new answer' do
        expect do
          post :create, question_id: question, answer: attributes_for(:answer, :invalid), format: :json
        end.to_not change(Answer, :count)
      end
    end

    context 'non-authenticated' do
      it 'redirects to root_path' do
        post :create, question_id: question, answer: attributes_for(:answer)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in(user) }

    it 'assigns requested answer to @answer' do
      patch :update, id: answer, question_id: question, answer: attributes_for(:answer), format: :json
      expect(assigns(:answer)).to eq answer
    end

    it 'changes answer attributes' do
      patch :update, id: answer, question_id: question, answer: { body: 'updated' }, format: :json
      answer.reload
      expect(answer.body).to eq 'updated'
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in(user)
      answer
      anothers_answer
    end

    context 'own answer' do
      it 'deletes answer' do
        expect do
          delete :destroy, id: answer, question_id: question, format: :js
        end.to change(Answer, :count).by(-1)
      end

      it 'redirects to answer question path' do
        delete :destroy, id: answer, question_id: question, format: :js
        expect(response).to render_template :destroy
      end
    end

    context 'anothers answer' do
      it 'doesnt delete answer' do
        expect do
          delete :destroy, id: anothers_answer, question_id: question
        end.to_not change(Answer, :count)
      end
    end
  end

  describe 'PATCH #make_best' do
    context 'correct user' do
      before do
        sign_in(user)
        question.update(user: user)
        patch :make_best, id: answer, question_id: question, format: :js
      end

      it 'sets #best to true' do
        answer.reload
        expect(answer).to be_best
      end

      it 'renders #make_best template' do
        expect(response).to render_template :make_best
      end
    end

    context 'incorrect user' do
      before { sign_in(user) }

      it 'doesnt change #best' do
        expect do
          patch :make_best, id: answer, question_id: question, format: :json
          answer.reload
        end.to_not change(answer, :best)
      end
    end
  end

  describe 'PATCH #upvote' do
    before { sign_in(user) }

    it 'renders answer/vote.json.jbuilder' do
      patch :upvote, id: answer, format: :json
      expect(response).to render_template :vote
    end

    it 'save/delete upvote' do
      expect do
        patch :upvote, id: answer, format: :json
      end.to change(answer.votes.upvotes, :count).by 1
      expect do
        patch :unvote, id: answer, format: :json
      end.to change(answer.votes.upvotes, :count).by(-1)
    end
  end

  describe 'PATCH #downvote' do
    before { sign_in(user) }

    it 'renders answer/vote.json.jbuilder' do
      patch :downvote, id: answer, format: :json
      expect(response).to render_template :vote
    end

    it 'save/delete  downvote' do
      expect do
        patch :downvote, id: answer, format: :json
      end.to change(answer.votes.downvotes, :count).by 1
      expect do
        patch :unvote, id: answer, format: :json
      end.to change(answer.votes.downvotes, :count).by(-1)
    end
  end

  describe 'PATCH #unvote' do
    before { sign_in(user) }

    it 'renders answer/vote' do
      patch :unvote, id: answer, format: :json
      expect(response).to render_template :vote
    end
  end
end
