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
      standard_bet: 10
    }
  }
  START_MENU = {
    '1' => {text: 'Start round', method: 'start_round'},
    '2' => {text: 'End game', method: 'end_game'}
  }
  ROUND_MENU = {
    '1' => {text: 'Take card', method: 'player_take_card'},
    '2' => {text: 'Wait', method: 'player_wait'},
    '3' => {text: 'Show Cards', method: 'end_round'},
    '4' => {text: 'Exit to main menu', method: 'break'}
  }
  attr_reader :bank

  def initialize(rules_type = nil)
    rules_type ||= 'standard'
    @players = []
    @bank = 0
    @rules = RULES[rules_type.to_sym]
    @card_deck = create_deck
    create_players
    puts "players: #{@players}"
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
    @players.each do |item| 
      make_bet(item[:player])
      @rules[:cards_to_take_on_first_move].times { item[:player].take_card(@game_deck)}
    end
    calculate_score
    @players.each { |item| item[:player].print_cards}

    loop do
      system "clear"
      print_round_info
      @players.each { |item| item[:player].print_cards}
      @players.each do |item|
        if item[:player].is_a?(Person) 
          output = human_turn(item[:player])        
          # break if input == '0'   
        elsif item[:player].is_a?(Virtual)
          # Computer move
          puts "score: #{item[:score]}, win_score: #{@rules[:win_score]}"
          item[:player].make_move(item[:score], @rules[:win_score], @game_deck)
        end
      end
    end
  end

  def end_move
    calculate_score
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
    puts "End round"
    player.show_cards
    @players.each { |item| puts "Player #{item[:player].name} has cards: #{item[:player].cards.join(', ')}. Score: #{item[:score]}" }
    give_money_to_winner_from_bank(get_winner)
    # Ask what to do further
    # is it really needed?
  end

  def end_game
    puts "COWARD!!!"
    exit
  end

  def player_take_card(player)
    player.take_card(@game_deck)
  end

  def player_wait(player)
    player.wait
  end

  protected
  attr_writer :bank

  def get_players_names
    result = []
    @players.select { |item| result << item[:player].name}
    return result.join(', ')
  end

  def get_players_last_actions
    result = []
    @players.select { |item| result << item[:player].last_actions.last}
    return result.join("\n")
  end

  def print_round_info
    puts "Money in bank: #{@bank}"
    puts "Players in game: #{get_players_names}"
    puts "Previous turns:\n #{get_players_last_actions}"
  end 

  def give_money_to_winner_from_bank(winner)
    if winner.size == 1
      winner.increase_money_amount(self.bank)
    else
      winner.each { |item| item[:player].increase_money_amount(self.bank / winner.size) }
    end
    self.bank = 0
  end
  
  def make_bet(player, bet = nil)
    bet_amount ||= @rules[:standard_bet]
    player.decrease_money_amount(bet_amount) && self.bank += bet_amount
  end

  def get_winner
    score = 0
    @players.each_with_index do |player, index|
      winning_score = player.score if score < player.score
      # winner_index = index
    end
    return @players.select{ |item| item[:score] == winning_score}
  end
  
  def calculate_score
    @players.each do |item|
      item[:player].cards.each do |card|
        if card[:name][0] == 'A' # card is Ace
          item[:score] += (item[:score] + card[:value].max > @rules[:win_score] ? card[:value].min : card[:value].min)
        else
          item[:score] += card[:value]
        end
      end
    end
  end

  def create_virtual_players(count = 1)
    count.times do 
      @players << {player: Virtual.new(name: get_random_name), score: 0}
    end
  end

  def create_real_players(count = 1)
    count.times do
      puts 'Enter your name. E.g. Rico Carnbery'
      @players << {player: Person.new(name: gets.chomp), score: 0}
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