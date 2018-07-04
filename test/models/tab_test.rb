require 'test_helper'

class TabTest < ActiveSupport::TestCase

  test "Tabs can be created with url" do
    tab = build(:tab, title: nil)
    assert tab.valid?, "Empty title should be valid."
  end

  test "Tabs can be created with url and title" do
    tab = build(:tab)
    assert tab.valid?, "Title and Url should be valid."
  end

  test "Tabs cannot be created with title" do
    tab = build(:tab, url: nil)
    assert tab.invalid?, "Empty url should be invalid."
  end

  test "Tabs cannot be created without a user" do
    tab = build(:tab, user: nil)
    assert tab.invalid?, "Empty user should be invalid."
  end

end
