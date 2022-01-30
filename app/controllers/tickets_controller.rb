# frozen_string_literal: true

# Tickets controller
class TicketsController < ApplicationController
  include GameManager

  def show
    build_game_props
    render json: fetch_ticket(@game_id, @join_code)
  rescue GameRecordMissingError
    render json: { error: 'error while fetching ticket' }, status: :not_found
  end

  private

  def build_game_props
    raw_id = params[:id].to_s.split('-')
    @current_pin = raw_id[0]&.to_i(36).to_s
    @game_id = raw_id[1]&.match(/\w{6}/).to_a[0]
    @join_code = params[:id]
  end
end
