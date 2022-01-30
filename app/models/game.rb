# frozen_string_literal: true

# Game handler
class Game
  SEQUENCE = (0..90).to_a
  attr_reader :count, :tickets, :ticket_grids, :requested_count, :game_hash

  def initialize(persons = 1)
    @requested_count = persons
    @count = [persons + 3, 720].min
    generate_sub_sequences
    generate_tickets
  end

  def map_tickets
    return if @ticket_grids.present?

    @ticket_grids = tickets.map { |ticket| Ticket.new(ticket).grid }
  end

  def jsonize
    map_tickets
    temp = as_json
    temp.delete 'tickets'
    temp.delete 'sub_sequences'
    @game_hash = temp
  end

  def self.generate_number_outcome
    SEQUENCE[1, 90].shuffle
  end

  private

  def generate_tickets
    @tickets = []
    count.times do |i|
      @tickets << build_ticket(i)
    end
  end

  def generate_sub_sequences
    @sub_sequences = []
    9.times do |i|
      @sub_sequences.push(
        SEQUENCE[(10 * i) + 1, 10].combination(3).to_a.sample(count)
      )
    end
  end

  def build_ticket(index)
    ticket = []
    @sub_sequences.each do |sequence|
      ticket << sequence[index]
    end
    ticket.flatten.sample(15).sort
  end
end
