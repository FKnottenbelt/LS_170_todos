ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'capybara/minitest'
require 'tilt/erb'

require_relative '../todo.rb'

Capybara.app = Sinatra::Application

class TodoTest < Minitest::Test
  include Capybara::DSL

  def test_homepage_redirects_to_lists
    visit '/'
    assert page.has_content?("Todo Tracker")
  end

  def test_make_new_valid_todolist
    visit '/lists'
    click_link("New List")
    assert page.has_content?("Enter the name for your new list")

    fill_in 'list_name', with: 'Test List'
    click_button("Save")
    assert page.has_content?("Test List")
    assert page.has_content?("The list has been created")
  end

  def test_new_empty_todolist_gives_error
    visit '/lists'
    click_link("New List")
    assert page.has_content?("Enter the name for your new list")

    fill_in 'list_name', with: ' '
    click_button("Save")
    assert page.has_content?("List name must by between 1 and 100 characters")
  end

end
