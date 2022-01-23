# frozen_string_literal: true

# A module for authenticating requests using pin
module PinAuthentication
  # TODO: @r11n please change the static pins to a dynamic source
  PINS = %w[500081 533233 534102 500033 533308 535002].freeze
  attr_reader :current_pin

  def authenticate(headers = {})
    @headers = headers
    check_pin
  end

  private

  attr_reader :headers

  def check_pin
    @current_pin = http_pin_header
    return @current_pin if PINS.include? http_pin_header

    raise UnAuthorizedError, 'Wrong Pin or No Pin entered'
  end

  def http_pin_header
    return headers['OperatorPin'] if headers['OperatorPin'].present?
  end

  # for raising unauthorized error
  class UnAuthorizedError < StandardError
    def initialize(msg = 'Not Authorized')
      super
    end
  end
end
