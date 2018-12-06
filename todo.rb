require 'sinatra'
require 'tilt/erubis'
require 'sinatra/content_for'
require 'sinatra/reloader'

configure do
  enable :sessions
  set :session_secret, 'secret'
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
get "/lists/:index" do
  index = params[:index].to_i
  @list = session[:lists][index]
  erb :list_detail, layout: :layout
end

# Edit one list
get "/lists/:index/edit" do
  index = params[:index].to_i
  @list = session[:lists][index]
  erb :edit_list, layout: :layout
end

# Edit one list
post "/lists/:index" do
  index = params[:index].to_i
  new_list_name = params[:list_name].strip

  error = error_for_list_name(new_list_name)
  if error
    @list = session[:lists][index]
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    session[:lists][index][:name] = new_list_name
    session[:success] = 'The list has been created'
    redirect "/lists/#{index}"
  end
end