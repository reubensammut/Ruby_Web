require 'rubygems'
require 'sinatra'
require 'sinatra/cookies'
require 'user_moods_helper'
require 'messages_helper'
require 'json'

set :port, 8080
set :bind, '0.0.0.0'

before do
	@users = []
	init
end

get "/" do
	content_type 'html'
	erb :index
end

get "/GetPreviousUsername" do
	user = ( cookies[ :name ] == nil ? "" : cookies[ :name ] )
	JSON.generate({ :previous_user => user })
end

get "/GetAllUsers" do
	@users = get_users		if @users.empty?
	JSON.generate({ :all_users => @users })
end

get "/SaveMood" do
	username = params[ 'username' ]
	mood = params[ 'mood' ]
	
	return "" if username == nil || mood == nil || !(["angry", "chill", "happy", "sad"].member? mood)

	puts username
	cookies[ :name ] = username
	@users = get_users		if @users.empty?
	
	if !@users.include? username
		create_entry_and_file username
		@users.push username
	end
	
	insert_entry username, mood
	
	@messages = load_messages		if @messages == nil
	message = get_random_message( @messages )
	
	JSON.generate({ :message => message })
end

get "/GetMoodData" do
	@users = get_users		if @users.empty?
	mood_data = get_moods @users, ( Date.today - 6 ).strftime( "%Y%m%d" ).to_i
	JSON.generate( mood_data )
end
