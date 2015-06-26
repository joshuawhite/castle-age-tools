require_relative 'ca_global'

# 2A. command line cookie suffix
# -----------------
class Main < CaGlobal
  MARKET_URL = CA_BASE_URL + "trade_market.php"
  GUILD_URL = CA_BASE_URL + "guild_conquest_market.php"
  ESSENCE_URL = CA_BASE_URL + "guildv2_home.php?guild_id"

  # uses a particular cookie and finds available essenses in markets
  def essence_search
    options = {}
    OptionParser.new do |opts|
      opts.on("-a", "--[no-]attack", "Search for attack essence") do |a|
        options[:attack] = a
      end

      opts.on("-d", "--[no-]damage", "Search for damage essence") do |d|
        options[:damage] = d
      end

      opts.on("-e", "--[no-]defense", "Search for defense essence") do |e|
        options[:defense] = e
      end

      opts.on("-h", "--[no-]health", "Search for health essence") do |h|
        options[:health] = h
      end

      opts.on("-cCOOKIE", "--cookie=COOKIE", "End of login cookie") do |c|
        options[:cookie_end] = c
      end

    end.parse!

    for_joshua_cmd(options[:cookie_end]) { |name, agent, |
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
          if (options[:attack])
            atks = essence[0].text.split("/")
            if (atks.length == 2 and atks[0].to_i + 200 <= atks[1].to_i)
              avail_atk = atks[1].to_i - atks[0].to_i
              puts "#{avail_atk} atk available:\n#{ESSENCE_URL}=#{guild}"
            end
          end
          if (options[:defense])
            defs = essence[1].text.split("/")
            if (defs.length == 2 and defs[0].to_i + 200 <= defs[1].to_i)
              avail_def = defs[1].to_i - defs[0].to_i
              puts "#{avail_def} def available:\n#{ESSENCE_URL}=#{guild}"
            end
           end
          if (options[:damage])
            dmgs = essence[2].text.split("/")
            if (dmgs.length == 2 and dmgs[0].to_i + 200 <= dmgs[1].to_i)
              avail_dmg = dmgs[1].to_i - dmgs[0].to_i
              puts "#{avail_dmg} dmg available:\n#{ESSENCE_URL}=#{guild}"
            end
          end
          if (options[:health])
            heals = essence[3].text.split("/")
            if (heals.length == 2 and heals[0].to_i + 200 <= heals[1].to_i)
              avail_heal = heals[1].to_i - heals[0].to_i
              puts "#{avail_heal} health available:\n#{ESSENCE_URL}=#{guild}"
            end
          end
        }
      rescue Exception => ex
          puts "Error in essence search. #{ex.class}, Message: #{ex.message}"
      end
    }
  end
end

ca = Main.new
ca.essence_search
