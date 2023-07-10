class Account
  def initialize(params)
    @id = params['id']
    @name = params['name']
    @balance = 1000 # TODO
  end

  attr_reader :id, :name, :balance
end

class Category
  def initialize(id, name, assigned_amount, amount_remaining)
    @id = id
    @name = name
    @assigned_amount = assigned_amount
    @amount_remaining = amount_remaining
  end

  attr_reader :id, :name, :assigned_amount, :amount_remaining

  def assigned_amount_formatted
    format('%.2f', assigned_amount)
  end

  def amount_remaining_formatted
    format('%.2f', amount_remaining)
  end
end

class Transaction
  def initialize(params)
    @id = params['id']
    @amount = params['amount'].to_f
    @memo = params['memo']
    @inflow = params['inflow']
    @date = Date.new(*(params['date'].split('-').map(&:to_i))) # TODO REFACTOR
    @category_id = params['category_id']
    @account_id = params['account_id']
  end

  attr_reader :id, :amount, :memo, :inflow, :date, :category_id, :account_id
end
