require_relative '../helpers/test_helper'

class ListAcceptTest < CapybaraTestCase

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

  def test_clicking_on_list_gives_list_detail_page
    # setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'Vacation'
    click_button("Save")

    # when I am on the all list page
    visit '/lists'
    # and I click on a list
    click_link('Vacation')
    # I go the the list detail page
    assert_current_path("/lists/0")
    # where I see my lists name
    assert_content('Vacation')
    page.assert_selector('#todos')
  end

  def test_list_detail_page_has_link_to_all_lists
    # setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'Vacation'
    click_button("Save")

    # when I am on the list detail page
    click_link('Vacation')
    # I can click the All lists link
    click_link("All lists")
    # and be taken to the all lists page
    assert_current_path("/lists")
  end
end
