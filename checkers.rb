require 'colored'
require 'debugger'
require './human'

class Piece

	attr_accessor :pos, :color, :char, :my_board, :king

	def initialize(my_board, pos, color)
		@my_board = my_board
		@pos = pos
		@color = color
		@char = assign_char
		@king = false
	end

	def assign_char
		unless self.king
			self.color == :white ? "  ".white : "  ".red
		else
			self.color == :white ? " K ".bold.white : " K ".bold.red
		end
	end

	def diffs_empty
		if self.color == :white && !self.king
			[ [-1, 1], [-1,-1] ]
		elsif self.color == :red && !self.king
			[ [1,1], [1,-1] ]
		else
			[ [-1, 1], [-1,-1], [1,1], [1,-1] ]
		end
	end

	def diffs_take
		king_take = enemies_around.map do |pair|
			pair.map! { |num| num * 2 }
		end

		if self.color == :white && !self.king
			king_take.select{ |coord| coord[0] < 0}
		elsif self.color == :red && !self.king
			king_take.select{ |coord| coord[0] > 0}
		else
			king_take
		end
	end

	def valid_moves
		valid_jumps + valid_slides
	end

	def valid_jumps
		jumping_piece = self.dup

		curr_jumps = jumping_piece.diffs_take.map { |coord| jumping_piece.add(coord) }
		# curr_jumps.select { |coord| on_board?(coord) }

		if curr_jumps.flatten.empty?
			[]
		else
			next_jumpers = []
			curr_jumps.each do |coord|
				next_jumper = jumping_piece.dup
				next_jumper.pos = coord
				next_jumpers << next_jumper
			end
			(curr_jumps + (next_jumpers.map { |obj| obj.valid_jumps }.flatten(1))).select { |coord| on_board?(coord) }
		end
	end

	def valid_slides
		temp = (diffs_empty - anyone_around)
		temp.map { |diff| add(diff) if on_board?(add(diff)) }.compact
	end

	def enemies_around
		spots = [ [1,1], [-1,-1], [1, -1], [-1, 1] ]
		spots.select do |coord|
			# new_coord = [ spot[0] + coord[0], spot[1] + spot[1] ]
			my_board.occupant(self.add(coord)) && (my_board.occupant(self.add(coord)).color != self.color)
		end
	end

	def anyone_around
		spots = [ [1,1], [-1,-1], [1, -1], [-1, 1] ]
		spots.select do |coord|
			my_board.occupant(self.add(coord))
		end
	end

	def move!(to_coord)
		self.pos = to_coord
	end

	def add!(coord)
		self.pos[0] += coord[0]
		self.pos[1] += coord[1]
		self.pos
	end

	def add(coord)
		temp = self.pos.dup
		temp[0] += coord[0]
		temp[1] += coord[1]
		temp
	end

	def on_board?(coord)
		coord.all? { |num| num.between?(0,7) }
	end


end

class Board

	attr_accessor :pieces

	def initialize
		init_pieces
	end

	def make_piece(board, pos, color)
		pieces << Piece.new(board, pos, color)
	end

	def occupant(coord = [-1,-1], &blk)
		blk ||= Proc.new { |piece| piece.pos == coord }

		piece_array = @pieces.select { |piece| blk.call(piece) }
		if piece_array.empty?
			return nil
		elsif piece_array.count == 1
			return piece_array.first
		else
			return piece_array
		end
	end

	def print
		formated_arrays = format
		puts "   #{Array(0..7).join("  ")}"
		formated_arrays.each do |line|
			puts line.join("")
		end
	end

	def init_pieces
		@pieces = []
		starting_pieces(5,7, :white)
		starting_pieces(0,2, :red)
	end

	def starting_pieces(row_min, row_max, color)
		
		if color == :white
			remainder1, remainder2 = 1, 0
		else
			remainder1, remainder2 = 0, 1
		end

		Array(row_min..row_max).each do |line_index|
			Array(0..7).each do |tile_index|
				if line_index % 2 == remainder1
					if tile_index % 2 == remainder2
						coord = [ line_index, tile_index ]
						make_piece(self, coord, color)
					end
				elsif line_index % 2 == remainder2
					if tile_index % 2 == remainder1
						coord = [ line_index, tile_index ]
						make_piece(self, coord, color)
					end
				end
			end
		end
		true
	end

	def write_pieces!(pict_board)
		pieces.each do |piece|
			y = piece.pos[0]
			x = piece.pos[1]

			pict_board[y][x] = piece.char
		end
		# pict_board
	end

	def format
		board =  Array.new(8) { Array.new(8) { "   " } }
		write_pieces!(board)
		new_board = []
		board.each_with_index do |line, line_index|
			new_line = line.each_with_index.map do |tile, tile_index|
				if line_index % 2 == 0
					tile_index % 2 == 0 ? "#{tile}" : "#{tile.on_black}"
				else
					tile_index % 2 == 0 ? "#{tile.on_black}" : "#{tile}"
				end
			end
			new_board << ["#{line_index} "] + new_line
		end
		new_board
	end
end

if $0 == __FILE__
	b = Board.new
	b.print
	b.occupant([1,0]).pos = [4,7]
	b.occupant([2,3]).pos = [4,3]
	b.occupant([5,4]).valid_jumps
end
