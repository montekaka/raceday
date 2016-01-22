class Racer
	# import the db
	# mongoimport --db raceday_development --collection race_results --file race_results.json
	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client['racers']
	end	

	def self.all(prototype={}, sort={}, skip=0, limit=nil)		
		tmp = {} #hash needs to stay in stable order provided
		sort.each {|k,v| 		
			tmp[k] = v  if [:first_name, :last_name, :gender, :group, :secs].include?(k)
		}
		sort=tmp
		Rails.logger.debug {"getting all zips, prototype=#{prototype}, sort=#{sort}, skip=#{skip}, limit=#{limit}"}

		prototype.each_with_object({}) {|(k,v), tmp| tmp[k.to_sym] = v; tmp}
		result=collection.find(prototype)
			.projection({_id:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
			.sort(sort)
			.skip(skip)
		result = result.limit(limit) if !limit.nil?
		return result
		#collection.find.projection({_id:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
	end
end