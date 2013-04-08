DatabaseCleaner.clean_with(:truncation)

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before('@no-txn,@selenium,@culerity,@celerity') do
  DatabaseCleaner.strategy = :truncation, {:except => %w[widgets]}
end

Before('@webkit,@javascript,@js') do
  DatabaseCleaner.strategy = :transaction
end

After('@webkit,@javascript,@js') do
  DatabaseCleaner.clean_with(:truncation)
end

Before('~@no-txn', '~@selenium', '~@webkit', '~@culerity', '~@celerity', '~@javascript', '~@js') do
  DatabaseCleaner.strategy = :transaction
end

