# frozen_string_literal: true

# Manager for game
module GameManager
  attr_reader :game_id, :game, :game_data

  include GameCleaner

  STORAGE_DIR = Rails.public_path.join('games')
  GAME_STATUSES = %w[started in_progress completed].freeze
  GENERAL_EVENTS = [
    { name: 'Jaldi 5', position_based: false, required_count: 5 },
    {
      name: 'First Line',
      position_based: true,
      required_count: 5,
      positions: [0, 1, 2, 3, 4, 5, 6, 7, 8]
    },
    {
      name: 'Second Line',
      position_based: true,
      required_count: 5,
      positions: [9, 10, 11, 12, 13, 14, 15, 16, 17]
    },
    {
      name: 'Third Line',
      position_based: true,
      required_count: 5,
      positions: [18, 19, 20, 21, 22, 23, 24, 25, 26]
    },
    { name: 'Full Housie', position_based: false, required_count: 15 }
  ].freeze

  def init_new_game(count = 1)
    return {} if count.blank?

    generate_game_id
    generate_game(count.to_i)
    build_game_data
    write_game
    delete_picks
  end

  def build_players(id, names = [])
    load_game(id)
    check_available_slots
    names.each do |name|
      ind = game_data['free_indexes'].shift
      game_data['users'].push(
        {
          name: name,
          code: "#{id}#{ind}",
          claimed_index: ind,
          join_code: "#{current_pin.to_i.to_s(36)}-#{id}#{ind}"
        }
      )
    end
    write_game(id)
  end

  def build_event(id, coordinates, type = 'fastest'); end

  def build_event_winner(id); end

  def next_pick(id); end

  def delete_game(id)
    raise GameRecordMissingError unless file_exists?(fname_for(id))

    delete_file(fname_for(id))
  end

  def fetch_ticket(id, join_code)
    load_game(id)
    user = game_data['users'].select { |a| a['join_code'] == join_code }[0]
    GameRecordMissingError if user.blank?

    {
      ticket: game_data['ticket_grids'][user['claimed_index']],
      user: user
    }
  end

  def fetch_picks(id)
    load_game(id)
    game_data['pick_sequence']
  end

  private

  # loads game data from given :id
  def load_game(id)
    raise GameRecordMissingError unless file_exists?(fname_for(id))

    @game_data = JSON.parse(safe_read(fname_for(id)))
  end

  # writes game data back into file
  def write_game(id = game_id)
    file = File.open(storage_path.join(fname_for(id)), 'w')
    file.rewind
    file.write JSON.generate(game_data)
    file.truncate(file.pos)
    file.close
  end

  def check_available_slots(count = 1)
    raise GameNoFreeSlotsError if game_data['free_indexes'].size < count

    raise GameInProgressError if game_data['status'] == 'in_progress'
  end

  # generates game data
  def build_game_data
    game.jsonize
    @game_data = game.game_hash.tap do |hash|
      hash['users'] = []
      hash['free_indexes'] = (1..game.count).to_a
      hash['pick_sequence'] = GameV2.generate_number_outcome
      hash['current_pick'] = nil
      hash['events'] = GENERAL_EVENTS
      hash['status'] = 'started'
      hash['id'] = game_id
    end
  end

  def delete_picks
    game_data.delete 'pick_sequence'
    game_data
  end

  def generate_game_id
    @game_id = Time.now.to_i.to_s(36)
  end

  def generate_game(count)
    @game = GameV2.new count
  end

  # Custom error for missing game
  class GameRecordMissingError < StandardError
    def initialize(msg = 'game not found or deleted')
      super
    end
  end

  # Custom error for in progress game
  class GameInProgressError < StandardError
    def initialize(msg = 'game is in progress')
      super
    end
  end

  # Custom error for in free slots
  class GameNoFreeSlotsError < StandardError
    def initialize(msg = 'all game slots are already claimed')
      super
    end
  end
end
