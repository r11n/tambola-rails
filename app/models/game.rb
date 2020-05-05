# frozen_string_literal: true

# Game handler
class Game
  SEQUENCE = (0..90).to_a
  attr_reader :count, :tickets
  def initialize(persons = 1)
    @count = persons
    generate_sub_sequences
    generate_tickets
  end

  def map_tickets
    tickets.map { |ticket| Ticket.new(ticket) }
  end

  private

  def generate_tickets
    @tickets = []
    (count + 3).times do |i|
      @tickets << build_ticket(i)
    end
  end

  def generate_sub_sequences
    @sub_sequences = []
    9.times do |i|
      @sub_sequences.push(
        SEQUENCE[(10 * i) + 1, 10].permutation(3).to_a.sample(count + 3)
      )
    end
  end

  def build_ticket(index)
    ticket = []
    @sub_sequences.each do |sequence|
      ticket << sequence[index]
    end
    ticket = ticket.flatten.sample(15).sort
    ticket
  end
end
