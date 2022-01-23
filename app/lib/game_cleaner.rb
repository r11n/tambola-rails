# frozen_string_literal: true

# a module for cleaning games
module GameCleaner
  include GameFileUtils

  def clean_operator_games
    return unless current_pin&.present?

    operator_game_files.each { |f| File.delete(f) }
  end

  def clean_all_games
    all_game_files.each { |f| File.delete(f) }
  end
end
