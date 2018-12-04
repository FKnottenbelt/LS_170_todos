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
    # when I visit the homepage
    visit '/'
    # I get redirected to the lists page
    assert_current_path("/lists")
    # Where I see the the title
    assert_content("Todo Tracker")
  end

  def test_make_new_valid_todolist
    # when I visit the lists page
    visit '/lists'
    # and I click on the new list link
    click_link("New List")
    # I get to asked to make a new list
    assert_content("Enter the name for your new list")

    # when I input a list name
    fill_in 'list_name', with: 'Test List'
    # and click the save button
    click_button("Save")
    # I will be redirected to the lists page where I see
    # my new list
    assert_content("Test List")
    # And I will get a succes message
    assert_content("The list has been created")
  end

  def test_new_empty_todolist_gives_error
    # when I visit the lists page
    visit '/lists'
    # and I click on the new list link
    click_link("New List")

    # when I don't input a list name (empty listname)
    fill_in 'list_name', with: ' '
    # and click the save button
    click_button("Save")
    # I won't be redirected to the lists page
    # and get an error message
    assert_content("List name must by between 1 and 100 characters")
  end

  def test_listname_must_be_unique
    # setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'non unique List'
    click_button("Save")

    # when I visit the lists page
    visit '/lists'

    # and I click on the new list link
    click_link("New List")

    # when I input a non unique list name
    fill_in 'list_name', with: 'non unique List'
    # and click the save button
    click_button("Save")
    # I won't be redirected to the lists page
    # and get an error message
    assert_content("List name must be unique")
  end
end
