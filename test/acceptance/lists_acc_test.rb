require_relative '../helpers/test_helper'

class ListAcceptTest < CapybaraTestCase

  def setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'Vacation'
    click_button("Save")
  end

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
    # I have a list called Vacation (see setup)
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
    # I have a list called Vacation (see setup)
    # when I am on the list detail page
    click_link('Vacation')
    # I can click the All lists link
    click_link("All lists")
    # and be taken to the all lists page
    assert_current_path("/lists")
  end

  def test_edit_list_name
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I see a edit lists link
    click_link("Edit List")
    # if I click the edit list link I go to a form on
    # the lists/<list id>/edit page
    assert_current_path("/lists/0/edit")
    # I will see a header saying 'Editing <listname'>
    assert_content("Editing 'Vacation'")

    # actions on edit page:
    # if I change the list name
    fill_in 'list_name', with: 'Sun Vacation'
    click_button("Save")
    # I will get the edit list page
    # and the list name will be changed in to my new name
    assert_current_path("/lists/0")
    assert_content('Sun Vacation')
    # and I will get a succes message
    assert_content("The list has been updated")
  end

  def test_cancel_in_edit_list_goes_back_to_list_detail
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    click_link("Edit List")
    # if a click the cancel link
    click_link("Cancel")
    # I go back to the list detail page
    assert_current_path("/lists/0")
  end

  def test_delete_a_list
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    click_link("Edit List")
    # And I click the link 'delete list'
    click_link("Delete List")
    # and I will be redirected to the all list page
    assert_current_path '/lists'
    # my list will be deleted
    refute_content("Vacation")
    # where I get a succes message
    assert_content("The list has been deleted")
  end
end
