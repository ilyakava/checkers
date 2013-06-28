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
				game_board.promote_kings
				return color.to_s if game_over?
			end
		end
	end

	def game_over?
		red_pieces = game_board.occupant {|piece| piece.color == :red }
		white_pieces = game_board.occupant {|piece| piece.color == :white }

		red_moves = red_pieces.map { |piece| piece.valid_moves }.flatten
		white_moves = white_pieces.map { |piece| piece.valid_moves }.flatten

		# REV: don't go over 80 char/line. You can avoid doing this
		# by using the forward slash "\" sign to concatenate one 
		# string across several lines:
		#
		# puts "#{red_pieces.count} red left with #{red_moves.count / 2} moves,"\
		# " #{white_pieces.count} white left with #{white_moves.count / 2} moves"

		puts "#{red_pieces.count} red left with #{red_moves.count / 2} moves, #{white_pieces.count} white left with #{white_moves.count / 2} moves"
		red_pieces.empty? || white_pieces.empty? || red_moves.empty? || white_moves.empty?
	end
end

if $0 == __FILE__
	Game.new
end