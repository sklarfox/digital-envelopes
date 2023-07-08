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
  def initialize(id, amount, memo, inflow, date, category_id, account_id)
    @id = id
    @amount = amount.to_f
    @memo = memo
    @inflow = inflow
    @date = Date.new(*date)
    @category_id = category_id
    @account_id = account_id
  end

  attr_reader :id, :amount, :memo, :inflow, :date, :category_id, :account_id
end
