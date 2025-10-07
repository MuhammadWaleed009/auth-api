class UsersController < ApplicationController
  before_action :authenticate, only: [ :show, :update, :close ]

  # POST /signup
  def signup
    if params[:user_id].blank? || params[:password].blank?
      render json: {
        message: "Account creation failed",
        cause: "Required user_id and password"
      }, status: :bad_request and return
    end

    user = User.new(
      user_id: params[:user_id],
      password: params[:password],
      nickname: params[:nickname],
      comment: params[:comment]
    )

    if user.save
      render json: { message: "Account successfully created" }, status: :ok
    else
      render json: {
        message: "Account creation failed",
        cause: user.errors.full_messages.join(", ")
      }, status: :bad_request
    end
  end

  # GET /users/:id
  def show
    user = User.find_by(user_id: params[:id])
    if user
      render json: {
        message: "User details by user_id",
        user_id: user.user_id,
        nickname: user.nickname,
        comment: user.comment
      }, status: :ok
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  # PATCH /users/:id
  def update
    return render(json: { message: "No permission for update" }, status: :forbidden) unless @current_user.user_id == params[:id]

    if @current_user.update(nickname: params[:nickname], comment: params[:comment])
      render json: { message: "User successfully updated" }, status: :ok
    else
      render json: {
        message: "Update failed",
        cause: @current_user.errors.full_messages.join(", ")
      }, status: :bad_request
    end
  end

  # POST /close
  def close
    if @current_user.destroy
      render json: { message: "Account and user successfully removed" }, status: :ok
    else
      render json: { message: "Account closure failed" }, status: :bad_request
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |user_id, password|
      user = User.find_by(user_id: user_id)
      if user&.authenticate(password)
        @current_user = user
      else
        render json: { message: "Authentication failed" }, status: :unauthorized and return
      end
    end
  end
end
