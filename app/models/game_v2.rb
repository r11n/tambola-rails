# frozen_string_literal: true

# Game handler
class GameV2
  SEQUENCE = (0..90).to_a

  attr_reader :count, :tickets, :ticket_grids, :requested_count, :game_hash

  def initialize(persons = 1)
    @requested_count = persons
    @count = [persons + 3, 720].min
    @tickets = []
    @temp = 0
    @num = (0..8).to_a
    @numbers = num_set
    generate_tickets
  end

  def map_tickets
    @ticket_grids = tickets.map { |ticket| Ticket.new(ticket).grid }
  end

  def print_grids
    @tickets.each { |ticket| Ticket.new(ticket).print_grid }
  end

  def jsonize
    map_tickets
    temp = as_json
    temp.delete 'tickets'
    %w[temp num numbers tickets].each { |e| temp.delete e }
    @game_hash = temp
  end

  def self.generate_number_outcome
    SEQUENCE[1, 90].shuffle
  end

  private

  def generate_tickets
    @tickets = []
    count.times do |i|
      @numbers = num_set if (i % 6).zero?
      @tickets << generate_ticket_sequence
    end
  end

  def generate_ticket_sequence
    ticket = []
    line = []
    15.times do |j|
      @num = (0..8).to_a if (@temp % 9).zero?

      @temp += 1
      line = [] if j < 15 && (j % 5).zero?
      k = @num.delete(@num.sample)
      if line.include? k
        q = k
        k = @num.delete(@num.sample)
        @num << q
      end
      line << k
      ticket << @numbers[k].delete(@numbers[k].sample)
    end
    ticket
  end

  def num_set
    [
      [90] + (1..9).to_a,
      (10..19).to_a,
      (20..29).to_a,
      (30..39).to_a,
      (40..49).to_a,
      (50..59).to_a,
      (60..69).to_a,
      (70..79).to_a,
      (80..89).to_a
    ]
  end
end
