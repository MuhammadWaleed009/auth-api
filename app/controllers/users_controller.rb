class UsersController < ApplicationController
  before_action :authorize, only: [ :show, :update, :close ]

  # POST /signup
  def signup
    user = User.new(user_params)
    user.nickname ||= user.user_id
    if user.save
      render json: {
        message: "Account successfully created",
        user: { user_id: user.user_id, nickname: user.nickname }
      }, status: :ok
    else
      render json: {
        message: "Account creation failed",
        cause: user.errors.full_messages.join(", ")
      }, status: :bad_request
    end
  end

  # GET /users/:user_id
  def show
    user = User.find_by(user_id: params[:user_id])
    return render json: { message: "No user found" }, status: :not_found unless user
    render json: { message: "User details by user_id", user: user.slice(:user_id, :nickname, :comment) }
  end

  # PATCH /users/:user_id
  def update
    user = User.find_by(user_id: params[:user_id])
    return render json: { message: "No user found" }, status: :not_found unless user
    unless user == @current_user
      return render json: { message: "No permission for update" }, status: :forbidden
    end
    if user.update(update_params)
      render json: { message: "User successfully updated", user: user.slice(:user_id, :nickname, :comment) }
    else
      render json: { message: "User updation failed", cause: user.errors.full_messages.join(", ") }, status: :bad_request
    end
  end

  # POST /close
  def close
    if @current_user.destroy
      render json: { message: "Account and user successfully removed" }
    else
      render json: { message: "Failed to delete account" }, status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def update_params
    params.permit(:nickname, :comment)
  end

  def authorize
    authenticate_or_request_with_http_basic do |user_id, password|
      user = User.find_by(user_id: user_id)
      if user&.authenticate(password)
        @current_user = user
      else
        render json: { message: "Authentication failed" }, status: :unauthorized
      end
    end
  end
end
