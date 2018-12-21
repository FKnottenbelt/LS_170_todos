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

  def test_count_count
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: false },
                        { name:'todo2' , completed: false },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal(3, todos_count(my_list))
  end

  def test_list_is_not_complete
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: false },
                        { name:'todo2' , completed: false },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal(false, list_complete?(my_list))
  end

  def test_list_is_complete
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: true },
                        { name:'todo2' , completed: true },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal(true, list_complete?(my_list))
  end

  def test_list_class_is_not_complete
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: false },
                        { name:'todo2' , completed: false },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal('uncomplete', list_class(my_list))
  end

  def test_list_class_is_complete
    my_list = { name: 'testlist' ,
                todos: [{ name:'todo1' , completed: true },
                        { name:'todo2' , completed: true },
                        { name:'todo3' , completed: true }
                      ]
    }
    assert_equal('complete', list_class(my_list))
  end

  def test_sort_list_by_completion
    my_lists = [
      { name: 'testlistA', todos: [{ name:'todo1a' , completed: true }]},
      { name: 'testlistB', todos: [{ name:'todo1b' , completed: false }]},
      { name: 'testlistC', todos: [{ name:'todo1c' , completed: false }]}
    ]

    expected = [
      {:name=>"testlistB", :todos=>[{:name=>"todo1b", :completed=>false}]},
      {:name=>"testlistC", :todos=>[{:name=>"todo1c", :completed=>false}]},
      {:name=>"testlistA", :todos=>[{:name=>"todo1a", :completed=>true}]}
      ]

    result_list = {}
    result = []
    myblock = Proc.new { |list, id| result << result_list[id] = list }

    sort_lists(my_lists, &myblock)

    assert_equal(expected, result )
  end

  def test_sort_todos_by_completion
    my_lists = { name: 'testlistA',
                 todos: [{ name:'todo1a', completed: false },
                         { name:'todo2a', completed: true },
                         { name:'todo3a', completed: false }
                        ]}

    expected = [
      { name:'todo1a', completed: false },
      { name:'todo3a', completed: false },
      { name:'todo2a', completed: true }
    ]

    result_todo = {}
    result = []
    myblock = Proc.new { |todo, id| result << result_todo[id] = todo}

    sort_todos(my_lists[:todos], &myblock)

    assert_equal(expected, result )
  end

  def test_load_list_gives_error_when_index_does_not_exist
    visit '/lists/200'
    assert_current_path '/lists'
    assert_content("The specified list was not found.")
  end

  def test_load_list_gives_list_when_index_does_exist
    # setup
    visit '/lists'
    click_link("New List")
    fill_in 'list_name', with: 'List 1'
    click_button("Save")

    visit '/lists/1'
    assert_current_path '/lists/1'
    assert_content("List 1")
  end

  def test_todo_index_returns_index
    my_list = { name: 'testlistA',
                todos: [{ id: 1, name:'todo1a', completed: false },
                        { id: 2, name:'todo2a', completed: true },
                        { id: 3, name:'todo3a', completed: false }
                       ]}

    todo_id = 3
    assert_equal(2, todo_index(my_list, todo_id))
  end
end

