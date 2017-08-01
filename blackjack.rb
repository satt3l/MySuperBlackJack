require 'json'
Dir['*.rb'].each { |file| require_relative file}

class BlackJack
  RULES = { 
    standard: {
      win_score: 21, 
      card_deck_count: 1, 
      player_count: 1, 
      ai_count: 1, 
      max_card_on_hand: 3, 
      cards_to_take_on_first_move: 2,
      standard_bet: 10,
      currency: 'RUB'
    }
  }
  START_MENU = {
    '1' => {text: 'Start round, make a bet', method: 'start_round'},
    '2' => {text: 'End game', method: 'end_game'}
  }
  ROUND_MENU = {
    '1' => {text: 'Take card', method: 'player_take_card'},
    '2' => {text: 'Wait', method: 'player_wait'},
    '3' => {text: 'Show Cards', method: 'end_round'}
  }
  attr_reader :bank

  def initialize(rules_type = nil)
    rules_type ||= 'standard'
    @players = []
    @bank = 0
    @rules = RULES[rules_type.to_sym]
    @wait_counter = 0
    @card_deck = create_deck
    @game_currency = @rules[:currency]
    @end_round = false
    @end_game = false
    create_players
    start_game
  end
  
  def create_deck(rules = RULES[:standard])
    @game_deck = Deck.new(rules[:card_deck_count])
  end

  def create_players(rules = RULES[:standard])
    create_real_players(rules[:player_count])
    create_virtual_players(rules[:ai_count])
  end

  def start_game
    loop do
      break if @end_game
      print_money_in_bank
      print_bet_amount
      print_players_in_game

      puts "What next?"
      START_MENU.each_pair do |seq, option|
        puts "#{seq}: #{option[:text]}"
      end
      input = gets.chomp
      break if input == '0'
      if START_MENU.key?(input)
        send(START_MENU[input][:method])
      end
    end
  end

  def start_round
    @end_round = false
    make_bet
    loop do
      break if @end_round || maximum_card_limit_reached?
      system "clear"
      calculate_score
      print_round_info
      @players.each { |item| item[:player].print_cards}
      @players.each do |item|
        if item[:player].is_a?(Person) 
          output = human_turn(item[:player])        
          # break if input == '0'   
        elsif item[:player].is_a?(Virtual)
          item[:player].make_move(item[:score], @rules[:win_score], @game_deck)
        end
      end
    end
  end

  def human_turn(player) # rename
    # return 
    ROUND_MENU.each_pair do |seq, option|
      puts "#{seq}: #{option[:text]}"
    end
    input = gets.chomp
    if ROUND_MENU.key?(input)
      send(ROUND_MENU[input][:method], player)
    end   
  end

  def end_round(player)
    @end_round = true
    puts "End round"
    player.show_cards
    @players.each { |item| puts "Player #{item[:player].name} has cards: #{item[:player].cards.join(', ')}. Score: #{item[:score]}" }
    give_money_to_winner_from_bank(get_winners)
    flush_players_properties
    loop do puts "Press any key" && gets && break end
  end

  def end_game
    @end_game = true
    puts "COWARD!!!"
  end

  def player_take_card(player)
    if maximum_card_limit_reached?(player)
      puts "Maximum limit of cards on hand #{@rules[:max_card_on_hand]} reached, suppose you decided to wait."
      sleep 1
      player_wait(player)
    else
      player.take_card(@game_deck)
    end
  end

  def player_wait(player)
    if @wait_counter > 2
      puts "Whoa!!! You want to wait forever? Naaa, thats not gonna happen. I call the end of this round"
      end_round(player)
      @wait_counter = 0
      return
    end
    player.wait 
    @wait_counter+= 1
  end
  
  def flush_players_properties
    @players.each { |item| item[:player].flush }
  end

  protected
  attr_writer :bank

  def get_players
    result = []
    @players.each { |item| result << item[:player].get_name_and_money}
    return result.join(', ')
  end

  def get_players_last_actions
    result = []
    @players.select { |item| result << item[:player].last_actions.last}
    return result.join("\n")
  end

  def print_bet_amount
    puts "Minimal bet: #{@rules[:standard_bet]} #{@game_currency}"
  end

  def print_game_info
    print_money_in_bank
    print_players_in_game
  end

  def print_players_in_game
    puts "Players in game: #{get_players}"
  end

  def print_money_in_bank
    puts "Money in bank: #{@bank} #{@game_currency}"
  end

  def print_last_players_turns
    puts "Previous turns:\n#{get_players_last_actions}"
  end

  def print_round_info
    print_money_in_bank
    print_players_in_game
    print_last_players_turns 
  end 

  def give_money_to_winner_from_bank(winners)
    # Yeah, i know, this is useless, but i found it pretty funny :)
    if winners.empty?
      puts "HAHAHAHAHA!!!! Your all are losers!!! I will take this money for myself!!!!"
      self.bank = 0
      return
    end 
    if winners.size == 1
      winners.first.increase_money_amount(self.bank)
      puts "Winner is #{winners.first.name} and bank #{self.bank}"
    else
      puts "Winners are: "
      winners.each { |player| puts "#{player.name}"; player.increase_money_amount(self.bank / winners.size) }
    end
    self.bank = 0
  end
  
  def make_bet(bet = nil)
    bet_amount ||= @rules[:standard_bet]
    @players.each do |item| 
      item[:player].decrease_money_amount(bet_amount) && self.bank += bet_amount
      @rules[:cards_to_take_on_first_move].times { item[:player].take_card(@game_deck)}
    end
  end

  def get_winners
    if have_player_with_win_score?
      return get_players_with_win_score
    else
      return get_winners_among_losers
    end
  end

  def have_player_with_win_score?
    @players.map { |item| item[:score] == @rules[:win_score]}.include?(true)
  end

  def get_players_with_win_score
    result = []
    @players.each do |item|
      result << item[:player] if item[:score] == @rules[:win_score]
    end
    result
  end
  
  def get_winners_among_losers
    result = []
    score = 0
    @players.each do |item|
      if item[:score] < @rules[:win_score]
        if score < item[:score]
          result = [item[:player]]
        elsif score == item[:score]
          result << item[:player]
        end
      end

      if result.empty?
        score = item[:score]
        result << item[:player]
      else
        if score < item[:score] && item[:score] < @rules[:win_score]
          score = item[:score]
          result.pop
          result << item[:player]
        end
      end
    end
    result
  end

  def calculate_score
    @players.each do |item|
      score = 0
      item[:player].cards.each do |card|
        if card[:name][0] == 'A' # card is Ace
          score += (item[:score] + card[:value].max > @rules[:win_score] ? card[:value].min : card[:value].max)
        else
          score += card[:value]
        end
      end
      item[:score] = score
    end
  end
  
  def maximum_card_limit_reached?(player = nil)
    if player
      res = player.cards.size == @rules[:max_card_on_hand]
    else
      cards_on_hands = []
      @players.each { |item| cards_on_hands << item[:player].cards.size }
      res = cards_on_hands.uniq == [@rules[:max]]
    end
    res
  end

  def create_virtual_players(count = 1)
    count.times do 
      @players << {player: Virtual.new(name: get_random_name), score: 0, wait_counter: 0, currency: @game_currency}
    end
  end

  def create_real_players(count = 1)
    count.times do
      puts 'Enter your name. E.g. Rico Carnbery'
      @players << {player: Person.new(name: gets.chomp.strip), score: 0, wait_counter: 0, currency: @game_currency}
    end
  end

  def get_random_name
    names = JSON.parse(File.read('resources/names.json')) # put to var!
    names['ai_names'][rand(names['ai_names'].size)]
  end
  
  def add_to_bank(value)
    @bank += value
  end
end

BlackJack.new