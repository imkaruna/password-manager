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
      @user = current_user
      session[:message]=""
      erb :'accounts/accounts.html'
    else
      session[:message]="Please login to view that page"
      redirect '/login'
    end

  end

  post '/accounts' do
      if (params[:account_name] != "") && (params[:account_password]!="")
        # creata n account that is pre associated and saved with the user.
        current_user.accounts.build(account_name: params[:account_name],account_username: params[:account_username], account_password: params[:account_password], password_expiry: params[:password_expiry], password_changed_date: DateTime.now)
        # current_user.accounts << Account.create(account_name: params[:account_name],account_username: params[:account_username], account_password: params[:account_password], password_expiry: params[:password_expiry], password_changed_date: DateTime.now)
        current_user.save
        redirect '/accounts'
      else
        erb :'accounts/accounts.html'
      end

  end

  get '/account/new' do
    @user = current_user
    erb :'accounts/new_account.html'
  end


  get '/accounts/:id' do
    if is_logged_in?
      @user = current_user
      @account = @user.accounts.find_by(id: params[:id])
      @account_password_expires_in = @account.password_expires.to_s + " days"
      erb :'accounts/show_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  post '/accounts/:id' do
    if is_logged_in?
      #binding.pry
      @user = current_user
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/show_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  get '/accounts/:id/edit' do
    if is_logged_in?
      @user = current_user
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/edit_account.html'
    else
      session[:message] = "You need to be logged in to view that page!"
      redirect '/login'
    end
  end

  post '/accounts/:id/edit' do
    if is_logged_in?
      @account = current_user.accounts.find_by(id: params[:id])
      @user = current_user
      @account_password_expires_in = @account.password_expires.to_s + "days"
      if params[:account_password] != @account.account_password
      else
        @account.password_changed_date = DateTime.now
      end
      @account.update(account_name: params[:account_name], account_username: params[:account_username], account_password: params[:account_password], password_expiry: params[:password_expiry])
      session[:message] = "Password changed on " + @account.password_changed_date
      redirect "/accounts/#{@account.id}"
      #current_user
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
        # the first time we call this method in a request, find the user,
        # the second time, just return the previously found user.
        # # how do we know if this method has been call before
        # if @user.nil?        # avoid hitting the db twice...
        #   @user = User.find(session[:id]) # #<User>
        # else
        #   @user
        # end

        # if @user exists, return otherwise, set it equal to user.find
        @user ||= User.find(session[:id])

      end
    end

end
