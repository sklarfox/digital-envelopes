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
    tuple_to_category_hash(result.first)
  end

  def load_transactions_for_category(id)
    sql = <<~SQL
    SELECT categories.*, 
           assigned_amount - sum(transactions.amount) AS amount_remaining
      FROM categories
      JOIN transactions ON categories.id = category_id
      WHERE categories.id = 4
      GROUP BY categories.id;
    SQL
    
    result = query(sql, id)

    result.map do |tuple|
      tuple_to_transaction_object(tuple)
    end
  end

  def all_categories
    sql = "SELECT * FROM categories ORDER BY name;"
    result = query(sql)

    result.map do |tuple|
      tuple_to_category_hash(tuple)
    end
  end

  def all_accounts
    sql = "SELECT * FROM accounts;"
    result = query(sql)

    result.map do |tuple|
      tuple_to_account_object(tuple)
    end
  end

  def sum_category_transactions_DEPRECATED(category_id)
    sql = <<~SQL
      SELECT sum(amount) FROM transactions
      WHERE category_id = $1 AND inflow = false;
    SQL

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

  def tuple_to_category_hash(tuple)
    { id: tuple['id'].to_i,
      name: tuple['name'],
      assigned_amount: tuple['assigned_amount'],
      amount_remaining: tuple['amount_remaining']
    }
  end

  def tuple_to_transaction_hash(tuple)
    { id: tuple['id'].to_i,
      amount: tuple['amount'],
      memo: tuple['memo'],
      inflow: tuple['inflow'] == 't',
      date: Date.new(*(params['date'].split('-').map(&:to_i))), # TODO REFACTOR
      category_id: tuple['category_id'],
      account_id: tuple['account_id']
    }
  end

  def tuple_to_account_hash(tuple)
    { id: tuple['id'],
      name: tuple['name'],
      balance: tuple['balance']
    }
  end

  def tuple_to_category_object_DEPRECATED(tuple) #TODO REMOVE
    id = tuple['id']
    name = tuple['name']
    assigned_amount = tuple['assigned_amount'].to_f
    amount_remaining = assigned_amount - sum_category_transactions(id)

    Category.new(id, name, assigned_amount, amount_remaining)
  end

  def tuple_to_transaction_object_DEPRECATED(tuple)
    Transaction.new(tuple)
  end

  def tuple_to_account_object_DEPRECATED(tuple)
    Account.new(tuple)
  end

  def add_new_category(name)
    sql = 'INSERT INTO categories (name) VALUES ($1);'
    query(sql, name)
  end

  def set_category_assigned_amount(amount, id)
    sql = 'UPDATE categories SET assigned_amount = $1 WHERE id = $2;'
    query(sql, amount, id)
  end

  def add_new_account(name)
    sql = 'INSERT INTO accounts (name) VALUES ($1);'
    query(sql, name)
  end

  def load_account(id)
    sql = 'SELECT * FROM accounts WHERE id = $1;'
    result = query(sql, id).first
    tuple_to_account_object(result)
  end

  def load_transactions_for_account(id)
    sql = 'SELECT * FROM transactions WHERE account_id = $1;'
    result = query(sql, id)

    result.map do |tuple|
      tuple_to_transaction_object(tuple)
    end
  end

  def add_new_transaction(amount, memo, date, category_id, account_id)
    inflow = category_id == '1'
    sql = <<~SQL
      INSERT INTO transactions (amount, memo, inflow, date, category_id, account_id)
      VALUES ($1, $2, $3, $4, $5, $6);
    SQL
    query(sql, amount, memo, inflow, date, category_id, account_id)
  end

  def change_category_name(id, new_name)
    sql = 'UPDATE categories SET name = $1 WHERE id = $2;'
    query(sql, new_name, id)
  end

  def change_account_name(id, new_name)
    sql = 'UPDATE accounts SET name = $1 WHERE id = $2;'
    query(sql, new_name, id)
  end

  def load_transaction(id)
    sql = <<~SQL
    SELECT t.id, t.amount, t.memo, t.inflow, t.date, 
           t.category_id, t.account_id,
           a.name AS account_name,
           c.name AS category_name
    FROM transactions AS t
    JOIN accounts AS a ON account_id = a.id
    JOIN categories AS c ON category_id = c.id
    WHERE t.id = $1;
    SQL
    
    query(sql, id).first
  end

  def change_transaction_details(amount, memo, date, category_id, account_id, id)
    inflow = category_id == '1'

    sql = <<~SQL
      UPDATE transactions
      SET amount = $1,
          memo = $2,
          inflow = $3,
          date = $4,
          category_id = $5,
          account_id = $6
          WHERE id = $7;
    SQL
    query(sql, amount, memo, inflow, date, category_id, account_id, id)
  end

  def delete_account(id)
    sql = 'DELETE FROM accounts WHERE id = $1'
    query(sql, id)
  end

  def delete_category(id)
    sql = 'DELETE FROM categories WHERE id = $1'
    query(sql, id)
  end

  def delete_transaction(id)
    sql = 'DELETE FROM transactions WHERE id = $1'
    query(sql, id)
  end
end
