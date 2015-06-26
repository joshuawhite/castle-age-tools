#!/usr/bin/ruby

require 'yaml'
require 'mechanize'

CA_BASE_URL = "https://web3.castleagegame.com/castle_ws/"
ARMY_URL = CA_BASE_URL + "army.php"

begin
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Safari'

	accounts = YAML.load_file("../army_config.yaml") 
  accounts.each {|account, cookie|

		puts "==========#{account}=========="

	  # This is the cookie for the user we are maquerading as
	  cookie_object = Mechanize::Cookie.new :domain => '.web4.castleagegame.com', 
	    :name => "CA_46755028429", :value => cookie, :path => '/'
	  agent.cookie_jar << cookie_object

		army_codes = IO.readlines("../army_codes.txt")

		army_codes.each do |code|
			code = code.chomp
			page = agent.post(ARMY_URL, {'army_code' => code, 
				"action" => "invite_army_code", 'ajax' => '1', 'ajax' => '1'})

			# Need to translate "page" object to "response.body"
			#response_match = page.parser.xpath("//span[@class='result_body']")

			response_re = /\<span class=\"result_body\"\>(.*)\<\/span\>/
			response_match = response_re.match(response.body)
			if response_match
			  response_string = "#{response_match[1]}"
			else
			  response_string = "No response (#{code})"
			end

			number_left_re = /\<b\>(\d+)\<\/b\>/
			number_match = number_left_re.match(response.body)
			if number_match 
			  puts "#{response_string} (#{code}, #{number_match[1]} left)"
			else 
			  puts "#{response_string} for #{code} - error, check cookie"
			end

			if number_match[1] == "0"
				puts "No more invites left"
				break
			end
		end

		puts "end of #{account}'s army invites\n\n"
	}
rescue Exception => ex
    puts "Something bad happened in army. Class: #{ex.class}, Message: #{ex.message}"
end
