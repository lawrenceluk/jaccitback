class GameController < ApplicationController
	before_filter :usercheck, :set_headers
	skip_before_filter  :verify_authenticity_token
	
	def seek
		if @user.game
			@user.game.destroy
		end
		@user.update_attribute(:status, "searching")
	end

	def check
		if @user.status == "searching"
			if Rails.env.development?
				rel = Player.where.not(username: @user.username).where("status == 'searching'")
    	else
      	# postgres
				rel = Player.where.not(username: @user.username).where("status = 'searching'")
    	end
			rel = Player.where.not(username: @user.username).where("status == 'searching'")
			if rel.exists?
				# get opponent
				opp = rel.first
				@message = "#{@user.username} #{opp.username}"
				# create game
				game = Game.new
				if game.save
					game.players << @user
					game.players << opp
					opp.update_attribute(:status, "matched")
					@user.update_attribute(:status, "matched")
				end
			else
				@message = "no"
			end
		elsif @user.status == "matched"
			pls = @user.game.players
			# if inconsistency
			if @user.game.players.first.status != @user.game.players.last.status
				# destroy the other game
				@user.game.players.first.update_attribute(:status, "none")
				@user.game.players.last.update_attribute(:status, "none")
				# back to queue
				@user.update_attribute(:status, "searching")
				@user.game.destroy
				return
			end
			@message = "#{pls[0].username} #{pls[1].username}"
		else
			@message = "none"
		end
	end

	def finished
		if @user.status == "matched" && @user.game
			score = params[:score].to_i
			game = @user.game
			if (!game.p1score)
				game.update_attribute(:p1score, score)
			else
				game.update_attribute(:p2score, score)
			end
			@user.update_attribute(:plays, @user.plays + 1)
			@user.update_attribute(:points, @user.points + score)
			if score > @user.highscore
				@user.update_attribute(:highscore, score)
			end
			@user.update_attribute(:status, "postgame")
		end
	end

	def postgame
		game = @user.game
		p1 = game.players.to_a[0]
		p2 = game.players.to_a[1]
		if (p1.status == "postgame" && p2.status == "postgame") || (p1.status == "done" && p2.status == "done")
			p1.update_attribute(:status, "done")
			p2.update_attribute(:status, "done")
			@message = "#{game.p1score} #{game.p2score}"
			return
		end
		@message = "no"
	end

	def interrupt
		if @user.status == "matched"
			puts @user.game
		end
		@user.update_attribute(:status, "none")
	end

	def usercheck
		if !params[:username]
			return
		end
  	check = Player.exists?(username: params[:username])
    if check
    	@message = "exists"
    	@user = Player.find_by(username: params[:username])
    else
			@message = "created"
			@user = Player.new(player_params)
			@user.requests = 0
			@user.plays = 0
			@user.points = 0
			@user.highscore = 0
			@user.username = params[:username]
			@user.save
		end
	end

	private
    def player_params
      params.permit(:username, :score)
    end
	  def set_headers
	    headers['Access-Control-Allow-Origin'] = '*'
	    headers['Access-Control-Expose-Headers'] = 'ETag'
	    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
	    headers['Access-Control-Allow-Credentials'] = 'true'
	    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
	    headers['Access-Control-Max-Age'] = '86400'
	  end

end