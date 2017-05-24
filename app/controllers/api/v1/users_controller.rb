class Api::V1::UsersController < ApplicationController
  before_action :authorize_request!

  def create
    user = User.new(users_params)
    if user.valid?
      DreamhostHostMakerJob.perform_later(user.valid_domain_name, user.username, user.valid_email)
      response = "User details are accepted.".to_json
    else
      response = user.errors.full_messages
    end
    render json: response
  end

  private

  def users_params
    params.permit(:email, :domain_name, :access_token)
  end

  def authorize_request!
    unless params[:access_token] == ENV['API_ACCESS_TOKEN']
      return render json: { success: 'failed', message: 'Wrong API Access Token' }, status: 403
    end
  end
end
