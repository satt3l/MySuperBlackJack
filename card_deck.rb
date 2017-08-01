class Deck
  attr_reader :cards, :cards_out

  def initialize(multiplier = 1)
    @cards = []
    @cards_out = []
    multiplier.times do   
      ['+', '<3', '^', '<>'].each do |suit|
        (2..10).each { |n| @cards << {name: "#{n}#{suit}", value: n}}
        @cards << {name: "K#{suit}", value: 10}
        @cards << {name: "Q#{suit}", value: 10}
        @cards << {name: "J#{suit}", value: 10}
        @cards << {name: "A#{suit}", value: [11, 1]}
      end
    end
  end

  def get_card
    flush if @cards.empty?
    card = @cards.delete_at(rand(@cards.size - 1))
    @cards_out.push(card)
    return card
  end

  def flush
    @cards = self.cards_out
    @cards_out = []
  end
  
end