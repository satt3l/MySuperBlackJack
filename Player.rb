# NOTE: файлик принято называть в нижнем регистре
class Player
  attr_reader :name, :cards, :money, :last_actions, :currency

  # NOTE: если это данные с настройками, скорее всего они не будут изменяться поэтому их лучше поместить в константу. Дочерний класс эту константу найти сможет. Но даже если бы и не мог, мы всегда можем получить доступ к константе `Player::DEFAULTS`. Это лучше потому что всегда есть риск изменить переменную класса, а тогда она изменится для всего дерева наследования и это может привести к ошибкам.
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

  # NOTE: думаю, нет особого смысла увеличивать значение `@money` на ноль. Поэтому лучше либо убрать параметр по умолчанию, либо сделать его каким-то ненулевым значением.
  def increase_money_amount(amount = 0)
    self.money += amount
  end

  def decrease_money_amount(amount = 0)
    raise InsufficientMoney, "Unable to decrease money amount to negative value. \\n
      Current money amount #{self.money}, decrease by #{amount}" if self.money - amount < 0
    self.money -= amount
  end

  # NOTE: разница между `take_card` и `add_card` трудно уловима. Я бы назвал `take_card_action`, намекая на то что это не только взятие карты (как добавление карты в массив карт игрока), но ещё и какое-то действие. А можно это сделать через блок: `player.take_card(card_deck) { |player| player.last_actions.push("#{player.name} take a card") }`. То есть сам метод отвечает за добавление карты в колоду, а в блоке мы уже можем передать дополнительные действия.
  def take_card(card_deck)
    # NOTE: эти выражения лушче просто написать на разных строках без `&&`.
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
    # NOTE: `return` не нужен.
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
