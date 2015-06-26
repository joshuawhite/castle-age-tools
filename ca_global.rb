require 'mechanize'
require 'yaml'
require 'optparse'

# Here I want to try using a block / yield to make the operations variant
# One for @ALL and one for @ANY

class CaGlobal
  # This is used to build all the urls in the app
  CA_BASE_URL = "https://web4.castleagegame.com/castle_ws/"
  LOGIN_URL = CA_BASE_URL + "connect_login.php"

  # LOGIN
  # user_config: contains :user and :password
  #
  # uses the login page form to log the user in, returns Cookie
  def login(user_config)

    return nil if (user_config['user'] == nil || user_config['pass'] == nil)

    # Go to Login Page
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    page = agent.get LOGIN_URL
    return nil if !form[0] 

    # submit form with username and password
    page = agent.post(LOGIN_URL, {'player_email' => user_config['user'], 
                                  'player_password' => user_config['pass']})

    # Collect / return cookie value (LIKE THIS?)
    agent.cookie_jar(:domain => '.web4.castleagegame.com')
    # Extra Credit: persist cookie to database
  rescue Exception => ex
    puts "Error in login! Error: #{ex.class}, Message: #{ex.message}"
  end

  # SETUP_AGENT
  # user_config: contains :cookie_prefix and :cookie_end
  #
  # Uses the cookie prefix and end values to build a CA cookie and adds it to
  # the mechanize agent
  # VERIFIED
  def setup_agent(user_config)
    # skip ones without cookie information
    return nil if (user_config['cookie_prefix'] == nil || user_config['cookie_end'] == nil)
    cookie_value = user_config['cookie_prefix'] + user_config['cookie_end']
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    cookie = Mechanize::Cookie.new(:domain => '.web4.castleagegame.com', 
                                   :name => "CA_46755028429", 
                                   :value => cookie_value, 
                                   :path => '/')
    agent.cookie_jar << cookie

    # Here I want to try a page and test to see if it needs to re-login
    # 1. Use agent to test the keep page
    # 2. If fail, then call login
    #   cookie = login(user_config)
    # 2a. After login, add cookie again
    #   return nil if (cookie == nil) 
    #   agent.cookie_jar << cookie

    return agent
  rescue Exception => ex
    puts "Error in setup_agent. #{ex.class}, Message: #{ex.message}"
  end

  # FOR_EVERY_USER
  #
  # This does the particular operation for every user in the yaml file
  def for_every_user
    players = YAML.load_file('player.yaml')
    players.each {|player,config|
      agent = setup_agent(config)
      next if agent == nil
      yield(player, agent)
    }
  rescue Exception => ex
    puts "Error in for_every_user. #{ex.class}, Message: #{ex.message}"
  end

  # FOR_ONE_USER
  #
  # This does the particular operation for the first available user in the yaml file
  # VERIFIED
  def for_one_user
    players = YAML.load_file('player.yaml')
    players.each {|player,config|
      agent = setup_agent(config)
      next if agent == nil
      yield(player, agent)
      break
    }
  rescue Exception => ex
    puts "Error in for_one_user. #{ex.class}, Message: #{ex.message}"
  end

  # FOR_JOSHUA_CMD
  # This works baby
  def for_joshua_cmd(cookie_end)
    players = YAML.load_file('player.yaml')
    config = players['Joshua']
    cookie_value = "#{config['cookie_prefix']}#{cookie_end}"
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    cookie = Mechanize::Cookie.new(:domain => '.web4.castleagegame.com', 
                                   :name => "CA_46755028429", 
                                   :value => cookie_value, 
                                   :path => '/')
    agent.cookie_jar << cookie
    yield(config, agent)
  rescue Exception => ex
    puts "Error in for_joshua_cmd. #{ex.class}, Message: #{ex.message}"
  end

end
