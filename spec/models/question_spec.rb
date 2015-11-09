require 'rails_helper'

describe Question do

  describe 'Associations' do

    it { should have_many(:answers).dependent(:destroy) }
    it { should belong_to :user }
  end

  describe 'Validations' do

    it { should validate_presence_of :title }
    it { should validate_presence_of :body }
    it { should validate_presence_of :user_id }
  end
end