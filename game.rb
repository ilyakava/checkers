require './checkers'
require './human.rb'

class Game

	attr_accessor :game_board, :players

	def initialize
		@game_board = Board.new
		@players = {
			red: HumanPlayer.new(game_board, :red),
			white: HumanPlayer.new(game_board, :white)
		}
		winner = game_loop
		puts "Game over, #{winner} wins!"
	end

	def game_loop
		loop do
			players.each do |color, player|
				game_board.print
				player.make_move
				return color.to_s if game_over?
			end
		end
	end

	def game_over?
		red_pieces = game_board.occupant {|piece| piece.color == :red }
		white_pieces = game_board.occupant {|piece| piece.color == :white }

		puts "#{red_pieces.count} red left, #{white_pieces.count} white left"
		red_pieces.empty? || white_pieces.empty?
	end
end

if $0 == __FILE__
	Game.new
end