class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_stocks = @user.stocks
  end

  def my_portfolio
    @user = current_user
    @user_stocks = current_user.stocks
  end

  def my_friends
    @friendships = current_user.friends
  end

  def search
    if params[:search_param].blank?
      flash.now[:danger] = 'No Search String Provided'
    else
      @users = User.search(params[:search_param])
      @users = current_user.except_current_user(@users)
      flash.now[:danger] = 'No user match this search criteria' if @users.blank?
    end
    respond_to do |format|
      format.js { render partial: 'friends/result' }
    end
  end

  def add_friend
    # user = User.find(params[:user])
    @friend = User.find(params[:friend])
    current_user.friendships.build(friend_id: @friend.id)
    if current_user.save!
      flash[:success] = 'Friend added successfully'
    else
      flash[:danger] = 'There was something wrong with adding friend'
    end
    redirect_to my_friends_path
  end
end
