require 'pg'

class DatabasePersistance
  def initialize
    @db = PG.connect(dbname: 'budget')
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def all_categories
    sql = 'SELECT * FROM categories;'
    result = query(sql)

    result.map do |tuple|
      id = tuple['id']
      name = tuple['name']
      assigned_amount = tuple['assigned_amount'].to_f
      amount_remaining = assigned_amount - sum_category_transactions(id)

      Category.new(id, name, assigned_amount, amount_remaining)
    end
  end

  def sum_category_transactions(category_id)
    sql = 'SELECT sum(amount) FROM transactions WHERE category_id = $1 AND inflow = false;'
    result = query(sql, category_id)
    result.first['sum'].to_f
  end

  def sum_all_inflows
    result = query('SELECT sum(amount) FROM transactions WHERE inflow = true;')
    result.first['sum'].to_f
  end

  def sum_all_assigned_amounts
    result = query('SELECT sum(assigned_amount) FROM categories;')
    result.first['sum'].to_f
  end
end