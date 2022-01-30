# frozen_string_literal: true

# Controller class of game
class GamesController < ApplicationController
  include GameManager
  before_action :authenticate_request, except: :index
  def index
    render json: { message: :ok }
  end

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

  def add_player
    build_players(params[:id], player_params[:players])
    render json: { message: 'Players successfully added to the game' }
  end

  def add_event
    build_event(params[:id], params[:coordinates], params[:type] || 'fastest')
    render json: { message: 'Event successfully added' }
  end

  def picks
    render json: { picks: fetch_picks(params[:id]) }
  end

  private

  def player_params
    params.permit(:id, :game, players: [],)
  end
end
