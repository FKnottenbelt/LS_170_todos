module Helpers
  def count_remaining_todos(list)
    list[:todos].select { |todo| todo[:completed] == false }.count
  end

  def todos_count(list)
    list[:todos].count
  end

  def list_complete?(list)
    count_remaining_todos(list) == 0 && todos_count(list) > 0
  end

  def list_class(list)
    list_complete?(list) ? 'complete' : 'uncomplete'
  end
end