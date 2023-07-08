require 'pg'

class DatabasePersistance
  def initialize
    @db = PG.connect(dbname: 'budget')
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def load_category(id)
    sql = 'SELECT * FROM categories WHERE id = $1;'
    result = query(sql, id)
    tuple_to_category_object(result.first)
  end

  def load_transactions_for_category(id)
    sql = 'SELECT * FROM transactions WHERE category_id = $1;'
    result = query(sql, id)

    result.map do |tuple|
      tuple_to_transaction_object(tuple)
    end
  end

  def all_categories
    sql = "SELECT * FROM categories WHERE name != 'Inflow';"
    result = query(sql)

    result.map do |tuple|
      tuple_to_category_object(tuple)
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

  def tuple_to_category_object(tuple)
    id = tuple['id']
    name = tuple['name']
    assigned_amount = tuple['assigned_amount'].to_f
    amount_remaining = assigned_amount - sum_category_transactions(id)

    Category.new(id, name, assigned_amount, amount_remaining)
  end

  def tuple_to_transaction_object(tuple)
    id = tuple['id']
    amount = tuple['amount']
    memo = tuple['memo']
    inflow = tuple['inflow'] == 'true'
    date = tuple['date'].split('-').map(&:to_i)
    category_id = tuple['category_id']
    account_id = tuple['account_id']

    Transaction.new(id, amount, memo, inflow, date, category_id, account_id)
  end

  def add_new_category(name)
    sql = 'INSERT INTO categories (name) VALUES ($1)'
    query(sql, name)
  end
end