class Player
  attr_reader :cards, :money, :type
  @defaults = {
    :start_money = 100,
  }

  def initialize(*args)
    @money = @defaults.merge(args)
    @score = 0
    @cards = []
    self.validate!
  end
  
  def self.validate!
    regexp = /.+ .+/i
  end

  def make_bet(amount)
    decrease_money_amount(amount) && return amount
    # some other actions
  end

  def wait
    # do nothing
  end

  def take_card(card_deck)
    add_card(card_deck)
    calculate_score
  end

  private
  attr_writer :cards, :money

  def increase_money_amount(amount = 0)
    self.money += amount
  end 

  def decrease_money_amount(amount = 0)
    raise NotEnoughMoney, "Unable to decrease money amount to negative value. \\n
      Current money amount #{self.money}, decrease by #{amount}" if self.money - money < 0
    self.money -= amount
  end
  
  def add_card(card_deck)
    self.cards << card_deck.get_card
  end
end