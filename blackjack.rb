require 'json'

class BlackJack
  RULES = [
    standard: {
      win_score: 21, card_deck_count: 1, player_count: 1, ai_count: 1, max_card_on_hand: 3
    }
  ]

  OPTIONS ={
    seq: 1, text: 'Take card', method: 'take_card',
    seq: 2, text: 'Wait', method: 'wait',
    seq: 3, text: 'Show cards', method: 'end_round',
    seq: 4, text: 'End game', method: 'end_game',
  }
  attr_reader :bank

  def initialize(rules_type = nil)
    rules_type ||= 'standard'
    @players = []
    @bank = 0
    @rules = RULES[rules_type.to_sym]

    create_deck
    create_players

    start_game
  end
  
  def create_deck(rules = RULES[:standard])
    @game_deck = Deck.new(rules[:card_deck_count])
  end

  def create_players(rules = RULES[:standard])
    create_virtual_players(rules[:ai_count])
    create_real_players(rules[:player_count])
  end

  def start_game
    do
      puts "What next?"
      OPTIONS.each do |option|
        puts "#{option[:seq]}: #{option[:text]}"
      end
      input = gets.chomp.to_i
      if OPTIONS.key?(input)
        send(OPTIONS[input])
      end
    loop
  end

  def end_round
    puts "End round"
    # Show cards and player name and score
    @players.each.cards { |card| puts card }
    # Show who is the winner
    # Increase money amount for player from bank money
    # Ask what to do further
  end

  def end_game
    puts "COWARD!!!"
    exit
  end

  def make_move
  end

  private
  
  def create_virtual_players(count = 1)
    count.times do 
      @players << Player.new(name: get_random_name)
    end
  end

  def create_real_players(count = 1)
    count.times do
      puts 'Enter your name. E.g. Rico Carnbery'
      @players << Player.new(name: name)
    end
  
  def get_random_name
    names = JSON.parse(File.read('resources/names.json')) # put to var!
    names['ai_names'](rand(names.size - 1))
  end
  
  def add_to_bank(value)
    @bank += value
  end
end