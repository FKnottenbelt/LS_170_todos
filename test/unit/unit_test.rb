require_relative '../helpers/test_helper'

class UnitTest < CapybaraTestCase
  include Helpers

  def test_listname_must_be_unique
    # setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'non unique List'
    click_button("Save")

    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'non unique List'
    click_button("Save")
    assert_content("List name must be unique")
  end

  def test_error_when_list_name_to_small
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: ''
    click_button("Save")
    assert_content("List name must by between 1 and 100 characters")
  end

  def test_error_when_list_name_to_big
    visit '/lists'
    click_link("New List")
    new_name = "a" * 101
    fill_in 'list_name', with: new_name
    click_button("Save")
    assert_content("List name must by between 1 and 100 characters")
  end

  def test_count_remainding_todos
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: false },
                        { name:'todo2' , completed: false },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal(2, count_remaining_todos(my_list))
  end
end