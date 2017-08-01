class Player
  attr_reader :name, :cards, :money, :last_actions

  @@defaults = {
    start_money: 100,
    currency: 'RUB'
  }

  def initialize(args={})
    @name = args[:name]
    @money = @@defaults[:start_money]
    @currency = @@defaults[:currency]
    @last_actions = []
    @cards = []
    #self.validate!
  end
  
  def self.validate!
    regexp = /.+ .+/i
  end

  def increase_money_amount(amount = 0)
    self.money += amount
  end 

  def decrease_money_amount(amount = 0)
    raise NotEnoughMoney, "Unable to decrease money amount to negative value. \\n
      Current money amount #{self.money}, decrease by #{amount}" if self.money - money < 0
    self.money -= amount
  end

  def take_card(card_deck)
    self.last_actions << "#{self.name} take a card" && add_card(card_deck)
  end
  
  def show_cards
    self.last_actions << "#{self.name} want to show cards"
  end

  def wait
    # do nothing
    self.last_actions << "#{self.name} waits"
  end
  
  def get_name_and_money
    return "#{self.name} with #{self.money} #{@currency}"
  end
  
  def flush
    reset_actions_and_cards
  end

  protected
  attr_writer :cards, :money, :last_actions
  
  def reset_actions_and_cards
    self.last_actions = []
    self.cards = []
  end

  def add_card(card_deck)
    self.cards << card_deck.get_card
  end
end