require "sequel"
DATABASE ||= Sequel.connect(ENV['DATABASE_URL'])
