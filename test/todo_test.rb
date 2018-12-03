ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'capybara/minitest'

require_relative '../todo.rb'

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.app = Sinatra::Application

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class TodoTest < CapybaraTestCase

  def test_homepage_redirects_to_lists
    visit '/'
    assert_current_path("/lists")
    assert_content("Todo Tracker")
  end

  def test_make_new_valid_todolist
    visit '/lists'
    click_link("New List")
    assert_content("Enter the name for your new list")

    fill_in 'list_name', with: 'Test List'
    click_button("Save")
    assert_content("Test List")
    assert_content("The list has been created")
  end

  def test_new_empty_todolist_gives_error
    visit '/lists'
    click_link("New List")
    assert_content("Enter the name for your new list")

    fill_in 'list_name', with: ' '
    click_button("Save")
    assert_content("List name must by between 1 and 100 characters")
  end

end
