# NOTE: расширение можно не указывать.
require_relative 'player.rb'
# NOTE: я бы назвал этот класс `Dealer` или `ComputerPlayer`, что-то вроде этого.
class Virtual < Player
  def make_move(current_score, winning_score, card_deck)
    if winning_score - current_score > 6
      take_card(card_deck)
    else
      wait
    end
  end

  def print_cards
    result = "*" * self.cards.size
    puts "#{self.name} has following cards: #{'*' * self.cards.size}"
  end
end
