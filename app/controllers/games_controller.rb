# frozen_string_literal: true

# Controller class of game
class GamesController < ApplicationController
  include GameManager
  before_action :authenticate_request
  def index; end

  def show
    render json: load_game(params[:id])
  rescue GameRecordMissingError => e
    render json: { message: e.message }, status: :not_found
  end

  def create
    render json: init_new_game(params[:count])
  end

  def destroy
    delete_game(params[:id])
    render json: { message: 'successfully deleted game' }
  rescue GameRecordMissingError => e
    render json: { message: e.message }, status: :not_found
  end

  def clear_all
    clean_operator_games
    render json: { message: 'successfully deleted all the operator games' }
  end

  def add_player; end

  def add_event; end
end
