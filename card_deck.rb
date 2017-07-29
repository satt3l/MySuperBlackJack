class Deck
  attr_reader :cards

  def initialize(multiplier = 1)
    @cards = []
    multiplier.times do   
      ['+', '<3', '^', '<>'].each do |suit|
        (2..10).each { |n| @cards << {name: "#{n}#{suit}", value: n}}
        @cards << {name: "K#{type}", value: 10}
        @cards << {name: "Q#{type}", value: 10}
        @cards << {name: "J#{type}", value: 10}
        @cards << {name: "A#{type}", value: [11, 1]}
      end
    end
    flush
  end

  def get_card
    flush if @cards_in.empty?
    @cards_out.push(@cards_in.delete_at(rand(@cards.size - 1)))
  end

  def flush
    @cards_in = self.cards
  end
  
end