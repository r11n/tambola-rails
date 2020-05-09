class GamesController < ApplicationController
  include GameManager
  before_action :authenticate_request
  def index
  end

  def show
    render json: {}
  end

  def create
    render json: init_new_game(params[:count])
  end

  def destroy
  end

  def clear_all
  end

  def add_player
  end

  def add_event
  end
end