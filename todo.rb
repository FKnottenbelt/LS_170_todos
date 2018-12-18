require 'sinatra'
require 'tilt/erubis'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?
require 'bundler/setup'

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

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

  def sort_lists(lists, &block)
    complete_lists, incomplete_lists =
      lists.partition { |list| list_complete?(list) }

    incomplete_lists.each { |list| yield list, lists.index(list) }
    complete_lists.each { |list| yield list, lists.index(list) }
  end

  def sort_todos(todos, &block)
    complete_todos, incomplete_todos =
      todos.partition { |todo| todo[:completed] }

    incomplete_todos.each { |todo| yield todo, todos.index(todo) }
    complete_todos.each { |todo| yield todo, todos.index(todo) }
  end

end

helpers do
  include Helpers
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# View all the lists
get '/lists' do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

def error_for_list_name(list_name)
  if !list_name.size.between?(1, 100)
    'List name must by between 1 and 100 characters'
  elsif session[:lists].any? { |list| list[:name] == list_name }
    'List name must be unique'
  end
end

# Create a new list
post '/lists' do
  new_list_name = params[:list_name].strip

  error = error_for_list_name(new_list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: new_list_name, todos: [] }
    session[:success] = 'The list has been created'
    redirect '/lists'
  end
end

# Render the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# View one list
get '/lists/:list_index' do
  @list_index = params[:list_index].to_i
  @list = session[:lists][@list_index]
  erb :list_detail, layout: :layout
end

# Edit existing list
get '/lists/:list_index/edit' do
  @list_index = params[:list_index].to_i
  @list = session[:lists][@list_index]
  erb :edit_list, layout: :layout
end

# Update existing list
post '/lists/:list_index' do
  @list_index = params[:list_index].to_i
  new_list_name = params[:list_name].strip

  error = error_for_list_name(new_list_name)
  if error
    @list = session[:lists][@list_index]
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    session[:lists][@list_index][:name] = new_list_name
    session[:success] = 'The list has been updated'
    redirect "/lists/#{@list_index}"
  end
end

# Delete existing list
post '/lists/:list_index/delete' do
  session[:lists].delete_at(params[:list_index].to_i)
  session[:success] = 'The list has been deleted'
  redirect '/lists'
end

def error_for_todo_name(todo_name)
  if !todo_name.size.between?(1, 100)
    'Todo name must by between 1 and 100 characters'
  elsif session[:lists].any? { |list| list[:todos].include?(todo_name) }
    'Todo name must be unique'
  end
end

# Add new todo to list
post '/lists/:list_index/todos' do
  @list_index = params[:list_index].to_i
  @new_todo_name = params[:todo].strip
  @list = session[:lists][@list_index]

  error = error_for_todo_name(@new_todo_name)
  if error
    session[:error] = error
    erb :list_detail, layout: :layout
  else
    session[:lists][@list_index][:todos] << { name: @new_todo_name ,
                                             completed: false }
    session[:success] = 'The list has been updated and Todo is added'
    redirect "/lists/#{@list_index}" # list_detail page
  end

end

# Cancel adding todo
get '/lists/:list_index/todos' do
  index = params[:list_index].to_i
  redirect "/lists/#{index}"
end

# Delete existing todo
post '/lists/:list_index/todos/:todo_index/delete' do
  list_index = params[:list_index].to_i
  todo_index = params[:todo_index].to_i
  session[:lists][list_index][:todos].delete_at(todo_index)
  session[:success] = 'The todo has been deleted'
  redirect "/lists/#{list_index}" # list_detail_page
end

# Update a todo completed status
post '/lists/:list_index/todos/:todo_index/check' do
  @list_index = params[:list_index].to_i
  @todo_index = params[:todo_index].to_i
  @list = session[:lists][@list_index]

  is_completed = params[:completed] == 'true'
  @list[:todos][@todo_index][:completed] = is_completed
  session[:success] = 'The todo status has been updated'

  redirect "/lists/#{@list_index}" # list_detail_page
end

# Complete all todos on a list
post '/lists/:list_index/complete' do
  @list_index = params[:list_index].to_i
  @list = session[:lists][@list_index]

  @list[:todos].each do |todo|
      todo[:completed] = true
  end

  session[:success] = 'All todos have been marked completed'
  redirect "/lists/#{@list_index}" # list_detail_page
end