require 'rails_helper'

describe Answer do

  describe 'Associations' do

    it { should belong_to :question }
    it { should belong_to :user }
  end

  describe 'Validations' do

    it { should validate_presence_of :body }
    it { should validate_presence_of :question_id }
    it { should validate_presence_of :user_id }
  end
end