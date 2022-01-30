# frozen_string_literal: true

# a class to generate ticket grid
class Ticket
  attr_reader :grid, :numbers, :row_proc, :row_size, :row_values, :sets

  def initialize(numbers)
    @numbers = numbers
    @jproc = proc { |a, b| '+' + (1..b).map { ''.rjust(a, '-') }.join('+') + '+' }
    arrange_ticket
  end

  def print_grid
    Rails.logger.info @jproc.call(2, 9)
    3.times do |a|
      row = row_values.call(a)
      Rails.logger.info "|#{row.map { |aa| aa.to_s.rjust(2, ' ') }.join('|')}|"
      Rails.logger.info @jproc.call(2, 9)
    end
    nil
  end

  private

  def arrange_ticket
    t = [Array.new(9), Array.new(9), Array.new(9)]
    row = 0
    15.times do |j|
      row = (j / 5.0).floor
      col = (numbers[j] / 10.0).floor
      col = 8 if col == 9
      t[row][col] = numbers[j]
    end
    build_procs
    @grid = t.flatten
    order_columns
  end

  def build_procs
    @row_proc = proc { |row| grid[(row % 3) * 9, 9] }
    @row_values = proc { |row| grid[(row % 3) * 9, 9] }
    @row_size = proc { |row| row_values.call(row).reject(&:nil?).size }
  end

  def check_rows
    excess_rows = []
    3.times do |a|
      excess_rows << a if row_size.call(a) > 5
    end
    reshuffle(excess_rows)
    order_columns
  end

  def reshuffle(excess)
    needy_indexes = [0, 1, 2] - excess
    excess.each do |rnum|
      while row_size.call(rnum) > 5
        needy_indexes.each do |i|
          break unless row_size.call(rnum) > 5

          row_values.call(rnum).each do |val|
            next if val.nil?

            ind = index(val)
            next unless val_empty?(i, ind)
            break if row_size.call(rnum) <= 5 || row_size.call(i) >= 5

            remove_number(rnum, val)
            assign_number(i, val)
          end
        end
      end
    end
  end

  def order_columns
    9.times do |q|
      col = column(q)
      sz = col.reject(&:nil?).size
      case sz
      when 3
        set_column(*col.sort, q)
      when 2
        col = swap_positions(col)
        set_column(*col, q)
      end
    end
  end

  def swap_positions(col)
    vcol = col.reject(&:nil?)
    scol = vcol.sort
    return col if vcol[0] == scol[0]

    indxs = scol.map { |a| col.index(a) }
    blk = [nil, nil, nil]
    blk[indxs[0]] = scol[1]
    blk[indxs[1]] = scol[0]
    blk
  end

  def assign_number(row, number)
    pos = index(number)
    row_index = ((row % 3) * 9) + pos
    current = grid[row_index]
    grid[row_index] = number if current.blank?
    return if current.blank?

    gt = number > current
    if gt
      if row == 2
        grid[row_index] = number
        move_to_upper_row(row, current, pos)
      else
        move_to_lower_row(row, number, pos)
      end
    else
      grid[row_index] = number
      if row.zero?
        move_to_lower_row(row, current, pos)
      else
        move_to_upper_row(row, current, pos)
      end
    end
  end

  def remove_number(row, number)
    grid[((row % 3) * 9) + index(number)] = nil
  end

  def set_column(num_a, num_b, num_c, col = -1)
    pos = col.negative? ? index(num_a || num_b || num_c) : col
    grid[pos] = num_a
    grid[9 + pos] = num_b
    grid[18 + pos] = num_c
  end

  def column(number)
    [grid[number], grid[9 + number], grid[18 + number]]
  end

  def move_to_upper_row(row, number, index)
    urow = [0, row - 1].max
    current = grid[urow * 9 + index]
    if current.blank?
      grid[urow * 9 + index] = number
      return
    end
    assign_number(urow, number) if current.present?
  end

  def move_to_lower_row(row, number, index)
    urow = [2, row + 1].min
    current = grid[urow * 9 + index]
    if current.blank?
      grid[urow * 9 + index] = number
      return
    end
    assign_number(urow, number) if current.present?
  end

  def lower_val_empty?(row, index)
    urow = [2, row + 1].min
    val_empty?(urow, index)
  end

  def upper_val_empty?(row, index)
    urow = [0, row - 1].max
    val_empty?(urow, index)
  end

  def val_empty?(row, index)
    ind_blank?((row % 3) * 9 + index)
  end

  def ind_blank?(index)
    grid[index].blank?
  end

  def index(number)
    diff = (number % 10).zero? ? 1 : 0
    (number / 10).to_i - diff
  end

  def is_needy?(row)
    row_size.call(row) < 5
  end
end
