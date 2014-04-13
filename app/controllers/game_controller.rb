class GameController < ApplicationController
	before_filter :usercheck

	def seek
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
				@message = "yes #{opp.username}"
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
			@message = "matched"
		else
			@message = "none"
		end
	end

	def finished
		if @user.status == "matched"
			score = params[:score].to_i
			game = @user.game
			if (!game.p1score)
				game.update_attribute(:p1score, params[:score])
			else
				game.update_attribute(:p2score, params[:score])
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
			game.destroy
			@message = "#{game.p1score} #{game.p2score}"
		end
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
			@user.username = params[:username]
			@user.save
		end
	end

	private
    def player_params
      params.permit(:username, :score)
    end

end