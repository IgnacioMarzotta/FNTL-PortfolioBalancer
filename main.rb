class Stock
	attr_reader :name, :price, :quantity
	
	def initialize(name:, price:, quantity:)
		@name = name
		@price = price
		@quantity = quantity
	end
	
	def value
		@price * @quantity
	end
end


class Portfolio
	attr_reader :stocks, :allocation
	
	def initialize(stocks:, allocation:)
		@stocks = stocks
		@allocation = allocation.transform_keys(&:to_s)
		
		validate_inputs!
	end

	def total_value
		@stocks.sum(&:value)
	end

	def current_stats
		total = total_value
		return [] if total.zero?
		
		@stocks.map do |stock|
			current_val = stock.value
			current_pct = (current_val / total.to_f).round(4)
			target_pct  = @allocation[stock.name]
			
			{
				ticker: stock.name,
				quantity: stock.quantity,
				value: current_val,
				current_allocation: "#{(current_pct * 100).round(2)}%",
				target_allocation:  "#{(target_pct * 100).round(2)}%",
				raw_current_pct: current_pct,
				raw_target_pct: target_pct
			}
		end
	end

	def rebalance_plan(tolerance: 0.0001)
		total = total_value
		return [] if total.zero?

		stocks.map do |stock|
			target_pct = allocation[stock.name]
			target_value = total * target_pct
			current_value = stock.value

			diff_value = (target_value - current_value)

			if diff_value.abs < tolerance
			{
				ticker: stock.name,
				action: :hold,
				quantity: 0.0,
				value: 0.0
			}
			else
			quantity_diff = diff_value / stock.price

			{
				ticker: stock.name,
				action: diff_value.positive? ? :buy : :sell,
				quantity: quantity_diff.round(6),
				value: diff_value.round(2)
			}
			end
		end
	end

	private
	def validate_inputs!
		
		# 0.1. Validar que allocation sume 100% (1.0)
		total_allocation = @allocation.values.sum
		unless (total_allocation - 1.0).abs < 0.0001
			raise ArgumentError, "La alocación debe sumar 100%. Suma actual: #{(total_allocation * 100).round(2)}%"
		end
		
		# Extraer nombres para comparar
		stock_names = @stocks.map(&:name)
		allocation_names = @allocation.keys
		
		# 0.2. Validar que todos los stocks en 'stocks' tengan su % definido en 'allocation'. 
		missing_allocation = stock_names - allocation_names
		if missing_allocation.any?
			raise ArgumentError, "Los siguientes stocks no tienen alocación definida: #{missing_allocation.join(', ')}"
		end
		
		# 0.3. Validar que no haya alocaciones para stocks que no existen
		extra_allocation = allocation_names - stock_names
		if extra_allocation.any?
			raise ArgumentError, "Hay alocación definida para stocks que no existen en el portafolio: #{extra_allocation.join(', ')}"
		end
	end
end


#1. Definir el portafolio actual
stocks = [
  Stock.new(name: "META", price: 485.32, quantity: 10),
  Stock.new(name: "AAPL", price: 189.15, quantity: 15),
  Stock.new(name: "GOOG", price: 142.08, quantity: 8),
  Stock.new(name: "AMZN", price: 175.22, quantity: 12),
  Stock.new(name: "NFLX", price: 605.88, quantity: 5),
  Stock.new(name: "TSLA", price: 163.57, quantity: 20)
]

allocation = {
	"META": 0.20,
	"AAPL": 0.20,
	"GOOG": 0.15,
	"AMZN": 0.15,
	"NFLX": 0.15,
	"TSLA": 0.15
}

portfolio = Portfolio.new(stocks: stocks, allocation: allocation)


#2. Mostrar estadisticas actuales del portafolio
puts "Valor Total del Portafolio: $#{portfolio.total_value}"
puts "-" * 30
puts "Estadísticas Actuales:"

portfolio.current_stats.each do |stat|
	puts "Stock: #{stat[:ticker]}"
	puts "* Cantidad: #{stat[:quantity]}"
	puts "* Valor: $#{stat[:value]}"
	puts "* Balance Actual:   #{stat[:current_allocation]}"
	puts "* Balance Objetivo: #{stat[:target_allocation]}"
	puts "* Estado: #{stat[:raw_current_pct] == stat[:raw_target_pct] ? 'Balanceado' : 'Desbalanceado'}"
	puts ""
end


#3. Calcular rebalance del portafolio usando el precio de cada stock y el allocation establecido. Mostrar resultado.
puts "-" * 30
puts "Plan de Rebalanceo:"

portfolio.rebalance_plan.each do |plan|
    ticker = plan[:ticker]
    action = plan[:action]
    
    case action
    when :buy
        puts "Comprar #{plan[:quantity]} acciones de #{ticker} "\
        "(aprox. $#{plan[:value]})"
    when :sell
        puts "Vender #{plan[:quantity].abs} acciones de #{ticker} "\
        "(aprox. $#{plan[:value].abs})"
    when :hold
        puts "#{ticker} ya está balanceado. No se requieren acciones."
    end
end