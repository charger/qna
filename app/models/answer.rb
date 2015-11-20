class Answer < ActiveRecord::Base

  include Attachmentable
  include HasUser
  include HasVotable

  belongs_to :question

  validates :body, :question_id, presence: true

  default_scope -> { order(best: :desc).order(created_at: :asc) }

  def make_best
    ActiveRecord::Base.transaction do
      self.question.answers.update_all(best: false)
      update!(best: true)
    end
  end
end
