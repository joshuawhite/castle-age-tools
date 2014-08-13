#!/usr/bin/ruby

require 'net/https'
require 'uri'
require 'yaml'

# Set of classes for Castle Age
#
# 3. Guild member list
# 4. Enemy guild recorder
# 5. Our guild recorder
# 
# 6. Guild database
#  - Guild: name, members
#  - Player: name, level, class, tower, position
#  - Battle: time, guild, W/L
#  - Activity: player, points
#  - Interaction: attacker, defender, W/L, special

class CastleAge

	@@headers = { 
		"Accept" => "*/*", 
		"Accept-Encoding" => "gzip,deflate,sdch",
		"Accept-Language" => "en-US,en;q=0.8",
		"Connection" => "keep-alive",
		"Content-Length" => "54",
		"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
		"Host" => "web3.castleagegame.com",
		"Origin" => "https://web3.castleagegame.com",
		"Referer" => "https://web3.castleagegame.com/castle_ws/index.php",
		"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36",
		"X-Requested-With" => "XMLHttpRequest"
	}

	# Lists current guild members - Player object
	def guild_member_list
		@guild_players = Array.new
		uri = URI.parse("https://web4.castleagegame.com/castle_ws/guildv2_battle.php")

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		request = Net::HTTP::Get.new(uri.request_uri)

		@@headers.each do |header, value|
			request.add_field header, value
		end

		accounts = YAML.load_file('army_config.yaml')		
		request.delete "Cookie"
		request.add_field "Cookie", accounts["Joshua"]

		response = http.request(request)
		@guild_players.push(process_member(response.body))

		@levels = Array.new
		@classes = Array.new

		@guild_players.each do |player|
			@levels.push(player.level)
			@classes.push(player.class_name)
		end

		avg_lvl = @levels.inject{ |sum, el| sum + el }.to_f / @levels.size
		puts "Average level is #{avg_lvl}"
		max_lvl = @levels.max
		puts "Max level is #{max_lvl}"

		warriors = @classes.select {|val| val == :warrior}.size
		puts "#{warriors} warrors."
		rogues = @classes.select {|val| val == :rogue}.size
		puts "#{rogues} rogues."
		mages = @classes.select {|val| val == :mage}.size
		puts "#{mages} mages."
		clerics = @classes.select {|val| val == :cleric}.size
		puts "#{clerics} clerics."
	end

	def process_member(response_body)

		player_num_re = /<div id=\\\"player(.*)\\\" class=\\\"player\\\" key=/
		player_num_match = player_num_re.match(response_body)

		class_re = /\/graphics\/class_(.*).gif\\\" style=/
		class_match = class_re.match(response_body)

		name_re = /<div class=\\\"player_name\\\" title=\\\".*\\\">(.*)<\/div>/
		name_match = name_re.match(response_body)

		level_re = /<div class=\\\"player_level\\\">Level: (.*)<\/div>/
		level_match = level_re.match(response_body)

		player = Player.new
		player.load(name_match[1], level_match[1], class_match[1], player_num_match[1])
		#player.info
		return player
	end

	def test_guild
		guild_players = Array.new
		guild_list_file = IO.binread("examples/guildv2_battle.html")
		whole_re = /\"(<div id=\\\"player.*?\\\" class=\\\"player\\\" key=\\\".*?\+\"<\/div>)\"/m
		guild_list_file.scan(whole_re).each do |member|
			guild_players.push(process_member(member[0]))
		end

		levels = Array.new
		classes = Array.new

		guild_players.each do |player|
			levels.push(player.instance_variable_get("@level"))
			classes.push(player.instance_variable_get("@class_name"))
		end

		avg_lvl = levels.inject(0){ |sum, lvl| sum + lvl.to_f } / levels.size
		puts "Average level is #{avg_lvl.round(2)}"
		max_lvl = levels.map(&:to_i).max
		puts "Max level is #{max_lvl}"

		warriors = classes.select {|val| val.intern == :warrior}.size
		war_pct = warriors.to_f / classes.size * 100.0
		puts "#{warriors} warrors #{war_pct.round(2)}%"
		rogues = classes.select {|val| val.intern == :rogue}.size
		rog_pct = rogues.to_f / classes.size * 100.0
		puts "#{rogues} rogues #{rog_pct.round(2)}%"
		mages = classes.select {|val| val.intern == :mage}.size
		mag_pct = mages.to_f / classes.size * 100.0
		puts "#{mages} mages #{mag_pct.round(2)}%"
		clerics = classes.select {|val| val.intern == :cleric}.size
		clc_pct = clerics.to_f / classes.size * 100.0
		puts "#{clerics} clerics #{clc_pct.round(2)}%"
	end

end

class Player

	# Class name enum
	@@class_names = [:warrior, :rogue, :cleric, :mage]

	def initialize
		@name = "Apple Bloom"
		@level = 1
		@class_name = :cleric
		@list_position = 0
	end

	def load(name, level, class_name, list_position)
		@name = name
		@level = level
		# Using intern to convert to the symbol, also uses cleric if not found
		@class_name = class_name if @@class_names.include?(class_name.intern)
		@list_position = list_position.to_i
	end		

	def tower_position
		return (@list_position % 25) + 1
	end

	def tower
		return (@list_position  / 25) + 1
	end

	def info
		puts "Tower #{tower}: \##{tower_position} #{@name}, #{@level}th level #{@class_name}"
	end
end

main = CastleAge.new
main.test_guild

#testPlayer = Player.new
#testPlayer.load('Juliette', 175, 'mage', 98)
#testPlayer.info
