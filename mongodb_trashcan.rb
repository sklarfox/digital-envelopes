require 'mongo'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')

def logAdjustment(amount, category) do
  doc = {
    category: category,
    amount: amount
  }

  
end