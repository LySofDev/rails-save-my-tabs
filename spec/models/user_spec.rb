require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a stable factory" do
    factory_user = build(:user)
    expect(factory_user).to be_valid
  end

  describe "#email" do

    it "cannot be empty" do
      user = build(:user, email: "")
      expect(user).to be_invalid
    end

    it "must be unique" do
      other_user = create(:user)
      expect(other_user).to be_persisted
      user = build(:user, email: other_user.email)
      expect(user).to be_invalid
    end

  end

  describe "#role" do

    it "is set to client by default" do
      user = create(:user)
      expect(user.client?).to be true
    end

    it "can be escalated to admin" do
      user = create(:user)
      expect(user.admin?).to be false
      user.admin!
      expect(user.admin?).to be true
    end

  end

  describe "#as_json" do

    it "hides the #password_digest" do
      user = create(:user)
      user_json = user.as_json
      expect(user_json.keys).not_to include :password_digest
    end

  end

  describe "#has_password" do

    it "returns true with the correct password" do
      user = build(:user)
      password = user.password
      expect(user.save).to be true
      expect(user.has_password(password)).to be true
    end

    it "returns false with the incorrect password" do
      user = create(:user)
      password = "invalid-password"
      expect(user.has_password(password)).to be false
    end

  end

  describe "#as_principal" do

    before :each do
      @user = create(:user)
    end

    it "returns the user id" do
      expect(@user.as_principal.values).to include @user.id
    end

    it "returns the user email" do
      expect(@user.as_principal.values).to include @user.email
    end

    it "returns the user role" do
      expect(@user.as_principal.values).to include @user.role
    end

  end

  describe "#as_token" do

    before :each do
      user = create(:user)
      @principal = user.as_principal
      @token = user.as_token
    end

    it "returns a JWT string" do
      expect(@token).to be_an_instance_of String
      expect(@token.length).to be > 0
    end

    it "contains the principal" do
      secret = Rails.application.credentials.jwt_secret
      payload = JWT.decode(@token, secret, true, { algorigth: 'HS256' })[0]["sub"]
      expect(payload.keys.map { |k| k.to_sym }).to eq @principal.keys
      expect(payload.values).to eq @principal.values
    end

  end

  describe "#tabs" do

    before :each do
      @user = create(:user)
    end

    it "can be empty" do
      expect(@user.tabs).to be_empty
    end

    it "can contain tabs" do
      tab_count = 3
      tab_count.times do
        create(:tab, user: @user)
      end
      expect(@user.tabs.count).to eq 3
    end
    
  end

end
