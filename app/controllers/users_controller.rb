class UsersController < ApplicationController

  def index
    session_id = cookies[:l_id]
    redirect_to :login and return if session_id.blank?
    redirect_to threads_path
  end

  def login
  end

  def auth
    #cookies[:l_id] = { :value => SecureRandom.uuid, :expires => 10.minutes.from_now }
    user = User.where(:email => params[:e], :password => params[:p]).first
    if !user.blank?
      response.set_cookie "l_id", SecureRandom.uuid
      puts user.id
      response.set_cookie "u_id", user.id
      redirect_to threads_path
    else
      render status: 401, plain: 'Provide valid creds'
      return
    end
  end
end