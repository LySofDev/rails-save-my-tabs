FactoryBot.define do
  factory :tab do
    user { create(:user) }
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence }
  end
end
