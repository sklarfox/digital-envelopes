require 'mongo'


class AdjustmentLog
  def initialize
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
  end

  def log_adjustment(amount, category)
    entry = {
      amount: amount,
      category: category
    }

    result = @client[:adjustments].insert_one(entry)
    puts result.n
  end

  def print_adjustment_history
    collection = @client[:adjustments]

    collection.find.each do |document|
      puts document
    end
  end
end
