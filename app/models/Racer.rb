class Racer
	# import the db
	# mongoimport --db raceday_development --collection race_results --file race_results.json
	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client['racers']
	end	
end