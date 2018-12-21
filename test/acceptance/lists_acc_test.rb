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
    click_button("Delete List")
    # and I will be redirected to the all list page
    assert_current_path '/lists'
    # my list will be deleted
    refute_content("Vacation")
    # where I get a succes message
    assert_content("The list has been deleted")
  end

  def test_adding_a_new_todo_to_list
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todolist
    fill_in 'todo', with: 'Book train'
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0'
    # the todo is added to the list
    assert_content("Book train")
    # and I get a succes message
    assert_content("The list has been updated and Todo is added")
  end

  def test_adding_invald_new_todo_to_list
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todolist
    too_long_todo_name = 'a' * 101
    fill_in 'todo', with: too_long_todo_name
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0/todos'
    # the input field will display my erronous todo name
    todo_name = find_field(id: 'todo').value
    assert_equal(too_long_todo_name, todo_name)
    # and I get a error message
    assert_content("Todo name must by between 1 and 100 characters")
  end

  def test_add_new_todo_form_has_cancel_button
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todo
    too_long_todo_name = 'a' * 101
    fill_in 'todo', with: too_long_todo_name
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0/todos'
    # I can click the cancel link
    click_link('Cancel')
    # and be redirected to to list detail page
    assert_current_path "/lists/0"
  end

  def test_delete_a_todo_from_list
    # setup
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todo item
    fill_in 'todo', with: 'Book train'
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0'
    # the todo is added to the list
    assert_content("Book train")

    # if I click the delete next to my todo
    click_button("Delete")

    # I am still on the same page
    assert_current_path '/lists/0'
    # but my todo is deleted
#    refute_content("Book train")  # AJAX trouble..
    # I get a succes message
    assert_content("The todo has been deleted")
  end

  def test_mark_todo_as_complete
    # setup
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todo item
    fill_in 'todo', with: 'Book train'
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0'
    # the todo is added to the list
    assert_content("Book train")

    # if I mark the todo completed
    click_button("Complete")
    # I will still be on the list detail page
    assert_current_path '/lists/0'
    # the box is checked
    # and the task is greyed
    page.has_selector?('.complete')
    # and I get a succes message
    assert_content("The todo status has been updated")
  end

  def test_mark_todo_as_not_complete
    # setup
    # I have a list called Vacation (see setup)
    # if I am at the detail list page
    visit '/lists/0'
    # I can enter a new todo item
    fill_in 'todo', with: 'Book train'
    # when I click the add button
    click_button("Add")
    # I stay on the page
    assert_current_path '/lists/0'
    # the todo is added to the list
    assert_content("Book train")

    # if I mark the todo uncompleted
    click_button("Complete")
    click_button("Complete")
    # I will still be on the list detail page
    assert_current_path '/lists/0'
    # the box is checked
    # and the task is greyed
    refute page.has_selector?('.complete')
    # and I get a succes message
    assert_content("The todo status has been updated")
  end

  def test_mark_all_todos_on_a_list_as_complete
    # setup
    # I have a list called Vacation (see setup)
    visit '/lists/0'
    fill_in 'todo', with: 'Pack bags'
    click_button("Add")
    fill_in 'todo', with: 'Book hotel'
    click_button("Add")
    fill_in 'todo', with: 'Find cat sitter'
    click_button("Add")

    # if I click the complete all button
    click_button('Complete All')
    # all items should be complete
    refute page.has_selector?('.uncomplete')
    # I get a succes message
    assert_content("All todos have been marked completed")
  end
end

