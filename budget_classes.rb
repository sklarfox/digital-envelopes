class Account
  def initialize(id, name)
    @id = id
    @name = name
  end

  attr_reader :id, :name
end

class Category
  def initialize(id, name, assigned_amount, amount_remaining)
    @id = id
    @name = name
    @assigned_amount = assigned_amount
    @amount_remaining = amount_remaining
  end

  attr_reader :id, :name, :assigned_amount, :amount_remaining
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
