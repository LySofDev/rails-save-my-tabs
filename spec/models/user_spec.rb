require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a stable factory" do
    factory_user = build(:user)
    expect(factory_user).to be_valid
  end

end
