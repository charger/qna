class Api::V1::AnswersController < Api::V1::BaseController
  before_action :load_question, except: :show

  def index
    respond_with @answers = @question.answers
  end

  def show
    respond_with @answer = Answer.find(params[:id])
  end

  private

  def load_question
    @question = Question.find(params[:question_id])
  end
end
