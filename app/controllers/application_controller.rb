require './config/environment'
require 'pry'

class ApplicationController < Sinatra::Base

  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    if is_logged_in?
      redirect '/accounts'
    else
      session[:message]=""
      erb :'index.html'
    end
  end

  get '/signup' do
    erb :'user/signup.html'

  end

  post '/signup' do

    if(params[:username]=="")||(params[:password]=="")||(params[:email]=="")
      session[:message]= "Please fill in all the fields"
      redirect '/signup'
    else
      @user = User.find_or_create_by(username: params[:username])
      @user.password= params[:password]
      @user.email = params[:email]
      @user.save
      session[:id]=@user.id
      session[:message] =""
      redirect '/accounts'
    end
  end

  get '/login' do
    if !is_logged_in?
      erb :'user/login.html'
    else
      redirect '/accounts'
    end
  end

  post '/login' do
    if (params[:username]=="") || (params[:password]=="")
      session[:message]="Username and Password cannot be blank!"
      redirect '/login'
    else
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        session[:message]=""
        redirect '/accounts'
      else
        session[:message] = "Could not authenticate username or password. Please try again!"
        redirect '/login'
      end
    end
  end

  get '/accounts' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      session[:message]=""
      erb :'accounts/accounts.html'
    else
      session[:message]="Please login"
      redirect '/login'
    end

  end

  post '/accounts' do
      if (params[:account_name] != "") && (params[:account_password]!="")
        @user = User.find_by(id: session[:id])
        @user.accounts << Account.create(account_name: params[:account_name],account_username: params[:account_username], account_password: params[:account_password], password_expiry: params[:password_expiry], password_changed_date: DateTime.now)
        @user.save
        redirect '/accounts'
      else
        erb :'accounts/accounts.html'
      end

  end

  get '/account/new' do
    @user = User.find_by(id: session[:id])
    erb :'accounts/new_account.html'
  end


  get '/accounts/:id' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/show_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  post '/accounts/:id' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/show_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  get '/accounts/:id/edit' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/edit_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  post '/accounts/:id/edit' do
    if is_logged_in?
      #binding.pry
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      if params[:account_password] != @account.account_password
        @account.password_changed_date = DateTime.now
        session[:message] = "Password changed "+@account.password_expires + "days ago"
      end
      @account.update(account_name: params[:account_name], account_username: params[:account_username], account_password: params[:account_password], password_expiry: params[:password_expiry])
      redirect "/accounts/#{@account.id}"
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  delete '/accounts/:id/delete' do
    @account = Account.find_by(id: params[:id])
    if is_logged_in?
      if session[:id] == @account.user_id
        @account.delete
        session[:message] = "Account deleted"
        redirect '/accounts'
      else
        session[:message] = "You need to be logged in to view that page!"
        redirect 'user/login'
      end
    end
  end

  get '/logout' do
    session.destroy
    redirect '/'
  end

    helpers do
      def is_logged_in?
        !!session[:id]
      end

      def current_user
        User.find(session[:id])
      end
    end

end
