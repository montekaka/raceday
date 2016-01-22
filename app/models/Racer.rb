class Racer

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def to_s
    "#{@id}: #{@number}, #{@number}, #{@first_name}"
  end

  def initialize(params={})
  	@id=params[:_id].nil? ? params[:id] : params[:_id].to_s
  	@number=params[:number].to_i
  	@first_name=params[:first_name]
  	@last_name=params[:last_name]
  	@gender=params[:gender]
  	@group=params[:group]
  	@secs=params[:secs].to_i
  end

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client['racers']
	end	

	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)		
		tmp = {} #hash needs to stay in stable order provided
		# sort.each {|k,v| 		
		# 	tmp[k] = v  if [:first_name, :last_name, :gender, :group, :secs].include?(k)
		# }
		# sort=tmp
		Rails.logger.debug {"getting all zips, prototype=#{prototype}, sort=#{sort}, skip=#{skip}, limit=#{limit}"}

		prototype.each_with_object({}) {|(k,v), tmp| tmp[k.to_sym] = v; tmp}
		result=collection.find(prototype)
			.projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
			.sort(sort)
			.skip(skip)
		result = result.limit(limit) if !limit.nil?
		return result
		#collection.find.projection({_id:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
	end
end