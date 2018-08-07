FactoryBot.define do
  factory :tab do
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence }
    user { create(:user) }
  end
end
