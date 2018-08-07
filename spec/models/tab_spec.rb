require 'rails_helper'

RSpec.describe Tab, type: :model do

  it "has a valid factory" do
    tab = build(:tab)
    expect(tab).to be_valid
    expect(tab.save).to be true
  end

  describe "#url" do

    it "cannot be empty" do
      tab = build(:tab, url: nil)
      expect(tab).to be_invalid
      tab.url = ""
      expect(tab).to be_invalid
      tab.url = "   "
      expect(tab).to be_invalid
    end

  end

  describe "#title" do

    it "can be empty" do
      tab = build(:tab, title: nil)
      expect(tab).to be_valid
      tab.title = ""
      expect(tab).to be_valid
      tab.title = "  "
      expect(tab).to be_valid
    end

  end

  describe "#user" do

    it "cannot be empty" do
      tab = build(:tab, user: nil)
      expect(tab).to be_invalid
    end

  end

end
