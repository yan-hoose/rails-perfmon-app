FactoryGirl.define do

  factory :user do
    sequence(:email) {|n| "user#{n}@exaampl.com"}
    password '123123123'
    password_confirmation {|u| u.password}
  end

  factory :website do
    name 'Das Website'
  end

  factory :users_website do
    association :user
    association :website
  end

  factory :request do
    association :website
    controller 'PostsController'
    action 'index'
    add_attribute(:method) {'GET'}
    format 'html'
    status 200
    view_runtime 10.49833
    db_runtime 29.2349
    total_runtime 58.2393
    time Time.now
    params { {'param1' => '5', 'param2' => 'true'} }
  end

  factory :note do
    association :website
    time Time.now
    text 'Note text'
  end

end