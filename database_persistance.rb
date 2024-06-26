require 'pg'

class DatabasePersistance
  ITEMS_PER_PAGE = 10

  def initialize
    @db = PG.connect(dbname: 'budget')
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def load_category(id)
    sql = <<~SQL
      SELECT categories.*,
             assigned_amount - sum(transactions.amount) AS amount_remaining,
             sum(transactions.amount) AS transaction_total
        FROM categories LEFT JOIN transactions ON categories.id = category_id
        WHERE categories.id = $1
        GROUP BY categories.id;
    SQL
    result = query(sql, id).first

    tuple_to_category_hash(result) if result
  end

  def all_categories
    sql = <<~SQL
    SELECT categories.*,
    assigned_amount - COALESCE(sum(transactions.amount), 0) AS amount_remaining,
    sum(transactions.amount) AS transaction_total
    FROM categories LEFT JOIN transactions ON categories.id = category_id
    GROUP BY categories.id;
    SQL
    result = query(sql)
    result.map { |tuple| tuple_to_category_hash(tuple) }
  end

  def load_categories(page)
    sql = <<~SQL
      SELECT categories.*,
             assigned_amount - COALESCE(sum(transactions.amount), 0) AS amount_remaining,
             sum(transactions.amount) AS transaction_total
      FROM categories LEFT JOIN transactions ON categories.id = category_id
      GROUP BY categories.id
      ORDER BY categories.name
      LIMIT 10 OFFSET $1;
    SQL
    offset = (page * 10) - 10
    result = query(sql, offset)

    result.map { |tuple| tuple_to_category_hash(tuple) }
  end

  def all_accounts
    sql = <<~SQL
        SELECT accounts.*,
          COALESCE(sum(CASE WHEN t.inflow THEN amount ELSE -(amount) END), 0)
            AS balance
        FROM accounts LEFT JOIN transactions AS t ON accounts.id = t.account_id
        GROUP BY accounts.id
        ORDER BY accounts.name;
    SQL
    result = query(sql)

    result.map { |tuple| tuple_to_account_hash(tuple) }
  end

  def to_be_assigned
    sum_all_inflows - sum_all_assigned_amounts
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
    return nil unless tuple

    { id: tuple['id'].to_i,
      name: tuple['name'],
      assigned_amount: tuple['assigned_amount'],
      amount_remaining: tuple['amount_remaining'] }
  end

  def tuple_to_transaction_hash(tuple)
    return nil unless tuple

    { id: tuple['id'].to_i,
      amount: tuple['amount'],
      memo: tuple['memo'],
      inflow: tuple['inflow'] == 't',
      date: Date.new(*(tuple['date'].split('-').map(&:to_i))),
      category_id: tuple['category_id'],
      account_id: tuple['account_id'] }
  end

  def tuple_to_account_hash(tuple)
    return nil unless tuple

    { id: tuple['id'],
      name: tuple['name'],
      balance: tuple['balance'] }
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
    sql = <<~SQL
          SELECT accounts.*,
                 COALESCE(sum(CASE WHEN t.inflow THEN amount ELSE -(amount) END), 0) AS balance
          FROM accounts
          LEFT JOIN transactions AS t ON accounts.id = t.account_id
          WHERE accounts.id = $1
          GROUP BY accounts.id ORDER BY accounts.name;
    SQL
    result = query(sql, id).first
    tuple_to_account_hash(result) if result
  end

  def max_account_page_number(id)
    sql = <<~SQL
      SELECT count(id) FROM transactions
      WHERE account_id = $1;
    SQL
    result = query(sql, id).first['count'].to_i
    return 1 if result == 0
    ((result - 1)/ 10) + 1
  end

  def max_budget_page_number
    sql = 'SELECT count(id) FROM categories;'

    result = query(sql).first['count'].to_i
    return 1 if result == 0
    ((result - 1)/ 10) + 1
  end

  def max_category_page_number(id)
    sql = <<~SQL
      SELECT count(id) from transactions
      WHERE category_id = $1;
    SQL
    result = query(sql, id).first['count'].to_i
    return 1 if result == 0
    ((result - 1)/ 10) + 1
  end

  def load_transactions_for_account(id, page)
    sql = <<~SQL
      SELECT * FROM transactions
      WHERE account_id = $1
      ORDER BY date DESC, memo LIMIT $2 OFFSET $3;
    SQL
    offset = (page * 10) - 10
    result = query(sql, id, ITEMS_PER_PAGE, offset)

    result.map do |tuple|
      tuple_to_transaction_hash(tuple)
    end
  end

  def load_transactions_for_category(id, page)
    sql = <<~SQL
      SELECT * FROM transactions
      WHERE category_id = $1
      ORDER BY date DESC, memo LIMIT $2 OFFSET $3;
    SQL
    offset = (page * 10) - 10
    result = query(sql, id, ITEMS_PER_PAGE, offset)

    result.map do |tuple|
      tuple_to_transaction_hash(tuple)
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
           a.name AS account_name, c.name AS category_name
    FROM transactions AS t
    JOIN accounts AS a ON account_id = a.id
    JOIN categories AS c ON category_id = c.id
    WHERE t.id = $1;
    SQL

    result = query(sql, id).first
    tuple_to_transaction_hash(result) if result
  end

  def change_transaction_details(amount, memo, date, cat_id, acc_id, id)
    inflow = cat_id == '1'

    sql = <<~SQL
      UPDATE transactions
      SET amount = $1, memo = $2,
          inflow = $3, date = $4,
          category_id = $5, account_id = $6
      WHERE id = $7;
    SQL
    query(sql, amount, memo, inflow, date, cat_id, acc_id, id)
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
