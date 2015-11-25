Rails.application.routes.draw do

  devise_for :users
  root to: 'questions#index'

  concern :votable do
    member do
      patch :upvote
      patch :downvote
      patch :unvote
    end
  end

  resources :questions, concerns: :votable do
    resources :comments, only: :create, defaults: {commentable: 'questions'}

    resources :answers, shallow: true, concerns: :votable do
      resources :comments, only: :create, defaults: {commentable: 'answers'}
      patch :make_best, on: :member
    end
  end
end