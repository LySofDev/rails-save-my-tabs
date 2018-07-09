def test_user
  User.create({
    email: "mac.hdz@gmail.com",
    password: "password",
    password_confirmation: "password"
  })
end

user = test_user

50.times { FactoryBot.create(:tab, user: user) }
