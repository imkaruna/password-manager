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
      erb :'index.html'
    end
  end

  get '/signup' do
    erb :'user/signup.html'
  end

  post '/signup' do
    if(params[:username]=="")||(params[:password]=="")||(params[:email]=="")
      redirect '/signup'
    else
      @user = User.find_or_create_by(username: params[:username])
      @user.password= params[:password]
      @user.email = params[:email]
      @user.save
      session[:id]=@user.id
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
      redirect '/login'
    else
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect '/accounts'
      else
        redirect '/login'
      end
    end
  end

  get '/accounts' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      erb :'accounts/accounts.html'
    else
      redirect '/login'
    end

  end

  post '/accounts' do
      if (params[:account_name] != "") && (params[:account_password]!="")
        @user = User.find_by(id: session[:id])
        @user.accounts << Account.create(account_name: params[:account_name],account_username: params[:account_username], account_password: params[:account_password])
        @user.save
        redirect '/accounts'
      else
        @message = "Error"
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
      redirect '/login'
    end
  end

  post '/accounts/:id' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/show_account.html'
    else
      redirect '/login'
    end
  end

  get '/accounts/:id/edit' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      erb :'accounts/edit_account.html'
    else
      redirect '/login'
    end
  end

  post '/accounts/:id/edit' do
    if is_logged_in?
      @user = User.find_by(id: session[:id])
      @account = @user.accounts.find_by(id: params[:id])
      @account.update(account_name: params[:account_name], account_username: params[:account_username], account_password: params[:account_password])
      redirect "/accounts/#{@account.id}"
    else
      redirect '/login'
    end
  end

  delete '/accounts/:id/delete' do
    @account = Account.find_by(id: params[:id])
    if is_logged_in?
      if session[:id] == @account.user_id
        @account.delete
        redirect '/accounts'
      else
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
