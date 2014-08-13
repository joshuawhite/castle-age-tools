require_relative 'ca_global'
# require_relative is what I am looking for! (but it behaves weirdly with file paths)

# 1. Army adder (done, tested)
# 2. Essence search (done, verified)
# 3. Personal player stats (done, verified)
# 4. Guild member list (done, non-integrated)
# 5. Enemy guild recorder
# 6. Our guild recorder
# 
# 7. Guild database
#  - Guild: name, members
#  - Player: name, level, class, tower, position
#  - Battle: time, guild, W/L
#  - Activity: player, points
#  - Interaction: attacker, defender, W/L, special

# -----------------
class Main < CaGlobal
  MARKET_URL = CA_BASE_URL + "trade_market.php"
  GUILD_URL = CA_BASE_URL + "guild_conquest_market.php"
  ESSENCE_URL = CA_BASE_URL + "guildv2_home.php?guild_id"
  KEEP_URL = CA_BASE_URL + "keep.php"

  ARMY_RESP_XPATH = "//span[@class='result_body']"
  ARMY_COUNT_XPATH = "?"


  # iterates through the army_config.yaml file and populates all the army
  # codes from the the army_codes.txt file
  # TODO: switch to use xpath and page.parser
  # TODO: find good army count xpath (not bold)
  def populate_army
    for_every_user { |name, agent|
      begin
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
      rescue Exception => ex
          abort "Error in populate_army. #{ex.class}, Message: #{ex.message}"
      end
    }
  end


  # uses a particular cookie and finds available essenses in markets
  # VERIFIED WORKS
  def essence_search
    for_one_user { |name, agent|
      begin
        page = agent.get MARKET_URL
        fail "Invalid page. Cookie is from web3 or web4?" if page.forms.size == 1

        guilds = Array.new
        page.forms.each {|form|
          if form["guild_id"]
            guilds << form["guild_id"]
          end
        }

        # Loops through each guild and checks to see if they have attack or damage essence available
        guilds.each {|guild|
          page = agent.post(GUILD_URL, {'guild_id' => guild, 'ajax' => '1', 'ajax' => '1'})
          essence = page.parser.xpath("//span[@style='color:#ec8900;']")
          atks = essence[0].text.split("/")
          if (atks.length == 2 and atks[0].to_i + 200 <= atks[1].to_i)
            avail_atk = atks[1].to_i - atks[0].to_i
            puts "#{avail_atk} atk available:\n#{ESSENCE_URL}=#{guild}"
          end
          defs = essence[1].text.split("/")
          if (defs.length == 2 and defs[0].to_i + 200 <= defs[1].to_i)
            avail_def = defs[1].to_i - defs[0].to_i
            puts "#{avail_def} def available:\n#{ESSENCE_URL}=#{guild}"
          end
          dmgs = essence[2].text.split("/")
          if (dmgs.length == 2 and dmgs[0].to_i + 200 <= dmgs[1].to_i)
            avail_dmg = dmgs[1].to_i - dmgs[0].to_i
            puts "#{avail_dmg} dmg available:\n#{ESSENCE_URL}=#{guild}"
          end
        }
      rescue Exception => ex
          puts "Error in essence search. #{ex.class}, Message: #{ex.message}"
      end
    }
  end


  # pulls down energy, stamina, attack, etc from the keep page
  # TODO: Add favor points? Guild coins?
  # VERIFIED WORKS
  def user_keep_stats
    for_every_user { |name, agent|
      begin
        page = agent.post('https://web4.castleagegame.com/castle_ws/keep.php', {'ajax' => '1'})

        # The only selector that is available is this awful style block
        stats = page.parser.xpath("//div[@style='width:112px;height:25px;font-size:15px;text-align:center;overflow:hidden;cursor:default;']")

        if (stats.length != 0)
          energy = stats[0].text[/[0-9]+/]
          stamina = stats[1].text[/[0-9]+/]
          attack = stats[2].text[/[0-9]+/]
          defense = stats[3].text[/[0-9]+/]
          health = stats[4].text[/[0-9]+/]
          army = stats[5].text[/[0-9]+/]

          puts "#{name}\nE:#{energy}, S:#{stamina}, A:#{attack}, D:#{defense}, H:#{health}, Army:#{army}\n"
        end
      rescue Exception => ex
          puts "Error in user_keep_stats. #{ex.class}, Message: #{ex.message}"
      end
    }
  end


  # gets guild stats from the guild battle page
  # @ANY
  def home_guild_stats
    puts "get_home_guild"
    for_one_user { |name, agent|
      puts "name: #{name}, agent: #{agent}"
    }
  end

  def fake_method(html)
    true
  end
end

ca = Main.new
ca.essence_search

