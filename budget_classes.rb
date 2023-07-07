class Account

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
  def initialize(result)

  end
end
