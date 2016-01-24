class Racer
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def to_s
    "#{@id}"
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

	def persisted?
		!@id.nil?
	end

	def created_at
		nil
	end

	def updated_at
		nil
	end

	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)		
		tmp = {} #hash needs to stay in stable order provided
		# sort.each {|k,v| 		
		# 	tmp[k] = v  if [:first_name, :last_name, :gender, :group, :secs].include?(k)
		# }
		# sort=tmp
		Rails.logger.debug {"getting all zips, prototype=#{prototype}, sort=#{sort}, skip=#{skip}, limit=#{limit}"}

		prototype.each_with_object({}) {|(k,v), tmp| tmp[k.to_sym] = v; tmp}
		#p prototype
		result=collection.find(prototype)
			.projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
			.sort(sort)
			.skip(skip)
		result = result.limit(limit) if !limit.nil?
		return result
		#collection.find.projection({_id:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
	end

	def self.find id
		result = collection.find(:_id=>BSON::ObjectId.from_string(id.to_s))
											 .projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
											 .first
		return result.nil? ? nil : Racer.new(result)
	end

	def save
		# instance method
		result = self.class.collection.insert_one(_id:@id, number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs:@secs)
		@id = result.inserted_id.to_s
	end

	def update(params)
		@number = params[:number].to_i
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@secs = params[:secs]
		@gender = params[:gender]
		@group = params[:group]

		params.slice!(:number, :first_name, :last_name, :gender, :group, :secs) if !params.nil?
		self.class.collection
							.find(_id:BSON::ObjectId.from_string(@id.to_s))
							.update_one(params)

	end

	def destroy
		self.class.collection
							.find(_id:BSON::ObjectId.from_string(@id.to_s))
							.delete_one
	end	

	def self.paginate(params)
		page = (params[:page] || 1).to_i
		limit = (params[:per_page] || 30).to_i
		skip = (page-1)*limit
		#sort = params[:sort] ||= {}
		racers = []
		all({}, {}, skip, limit).each do |doc|
			racers << Racer.new(doc)
		end
		total = all.count

		WillPaginate::Collection.create(page, limit, total) do |pager|
			pager.replace(racers)
		end
	end
end