# NOTE: обычно классы исключений заканчивают на `Error`, например: `NotEnoughMoneyError`.
# NOTE: также можно классы исключений поместить в каталог `errors`.
class InsufficientMoney < StandardError
end
