class ApplicationController < ActionController::API
  include PinAuthentication
  include ActionController::MimeResponds

  rescue_from UnAuthorizedError, with: -> { deny_access }

  def authenticate_request
    authenticate(request.headers)
  end

  private

  def deny_access
    render json: { message: 'Not Authorized' }, status: :unauthorized
  end
end
