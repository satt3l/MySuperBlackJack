# NOTE: расширение можно не указывать.
require_relative 'player.rb'
class Person < Player
  def print_cards
    result = self.cards.select { |card| card[:name] }.join(' ')
    puts "#{self.name} has following cards: #{result}"
  end
end
