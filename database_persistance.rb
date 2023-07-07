require 'pg'

class DatabasePersistance
  def initialize
    @db = PG.connect(dbname: 'budget')
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def all_categories
    sql = 'SELECT * FROM categories'
    result = query(sql)

    result.map do |tuple|
      id = tuple['id']
      name = tuple['name']
      assigned_amount = tuple['assigned_amount']
      amount_remaining = '50.00'
      Category.new(id, name, assigned_amount, amount_remaining)
    end
  end
end