require 'colored'

class Piece

	attr_accessor :pos, :color, :char

	def initialize(my_board, pos, color)
		@my_board = my_board
		@pos = pos
		@color = color
		@char = assign_char
	end

	def assign_char
		self.color == :white ? "  ".white : "  ".red
	end

	def diffs_empty
		if self.color == :white
			[ [-1, 1], [-1,-1] ]
		else
			[ [1,1], [1,-1] ]
		end
	end

	def diffs_take
		if self.color == :white
			[ [-2, 2], [-2,-2] ]
		else
			[ [2,2], [2,-2] ]
		end
	end

	def enemies_around
		spots = [ [1,1], [-1,-1], [1, -1], [-1, 1] ]
		spots.map do |coord|
			pot_occupant = my_board.occupant( self.add(coord) )
			pot_occupant && pot_occupant != self.color
		end
	end

	def add!(coord)
		self.pos[0] += coord[0]
		self.pos[1] += coord[1]
		self.pos
	end

	def add(coord)
		temp = self.pos
		temp[0] += coord[0]
		temp[1] += coord[1]
		temp
	end

	def valid_moves
		(diffs_empty - enemies_around) + (diffs_take & enemies_around)
	end		

end

class Board

	attr_accessor :pieces

	def initialize
		
	end

	def make_piece(board, pos, color)
		pieces << Piece.new(board, pos, color)
	end

	def occupant(coord)
		piece = @pieces.select { |piece| piece.pos == coord }.first
		piece ? piece : nil
	end

	def init_pieces
		@pieces = []
		starting_pieces(5,7, :white)
		starting_pieces(0,2, :red)
	end

	def print
		formated_arrays = format
		puts "   #{Array(0..7).join("  ")}"
		formated_arrays.each do |line|
			puts line.join("")
		end
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

	def write_pieces(pict_board)
		pieces.each do |piece|
			y = piece.pos[0]
			x = piece.pos[1]

			pict_board[y][x] = piece.char
		end
		pict_board
	end

	def format
		board =  Array.new(8) { Array.new(8) { "   " } }
		write_pieces(board)
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