require './checkers'

class HumanPlayer

	attr_accessor :play_board, :my_color

	def initialize(play_board, my_color)
		@play_board = play_board
		@my_color = my_color

	end

	def make_move
		begin
			move_pair = get_move
		rescue ArgumentError => e
			puts e.message
			retry
		end
		from, to = move_pair[0], move_pair[1]

		okay_moves = play_board.occupant(from).valid_moves

		if to.count > 2
			begin
				multiple_moves(to, from, okay_moves)
			rescue ArgumentError => e
				puts e.message
				return "False move, turn forfeited"
			end
			return "successful multimove"
		elsif play_board.occupant(from).valid_jumps.include?(to)
			delete(to, from)
			
		end
		play_board.occupant(from).move!(to)
	end

	def multiple_moves(to_moves, from, okay_moves)
		last_to = from
		until to_moves.empty?
			next_to = [to_moves.shift, to_moves.shift]

			unless okay_moves.include?(next_to)
				raise ArgumentError.new("You cannot move there")
			else
				play_board.occupant(last_to).move!(next_to)
				delete(last_to, next_to)
			end
			last_to = next_to.dup
		end
	end


	def delete(to, from)
		diff = [(to[0] - from[0]) / 2, (to[1] - from[1]) / 2]
		delete_pos = [from[0] + diff[0], from[1] + diff[1]]
		play_board.pieces.delete(play_board.occupant(delete_pos))
	end

	def get_move
		puts "#{my_color.to_s.capitalize}, where would you like to move from?"
		raw_move_from = gets.chomp
		from_coord = parse_input(raw_move_from)

		moving_piece = play_board.occupant(from_coord)

		unless raw_move_from =~ /[0-7],[0-7]/
			raise ArgumentError.new("You must enter two digits that are comma separated in y,x style")
		end

		if moving_piece == nil
			raise ArgumentError.new("You do not have a piece there, that's an empty spot!")
		elsif moving_piece.color != my_color
			raise ArgumentError.new("You cannot move your opponnent's piece!")
		end

		puts "#{my_color.to_s.capitalize}, where would you like to move that piece to?"
		raw_move_to = gets.chomp
		to_coord = parse_input(raw_move_to)
		
		unless raw_move_from =~ /[0-7],[0-7]/ && to_coord.count % 2 == 0
			raise ArgumentError.new("You must enter two digits that are comma separated in y,x style or\
				use the & symbol without spaces if you wish to make a multi-step move")
		end

		if to_coord.count == 2 && !moving_piece.valid_moves.include?(to_coord)
			raise ArgumentError.new("You cannot move there")
		end

		move_pair = [ from_coord, to_coord ]
	end

	def parse_input(str)
		str.split(/[,&]/).map{ |num_str| num_str.to_i }
	end

end