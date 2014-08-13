require 'yaml'
require 'mechanize'
# :( without a method this works, but it is not running the tests

invites_left = %{<div style="text-align:center;width:600px;padding: 10px 25px 10px 65px;color:#F0F8FF;font-family:Verdana; font-size:20px;font-weight:bold;">
        You have <b>20</b> available army invites left!
                Click below to invite Facebook friends to grow your army!
              </div>}

puts 'This is outside of the method boundary - Joshua'
players = YAML.load_file('player.yaml')
puts players['JJ']['cookie_prefix'] + 'hi'

  def test_yaml
    puts 'This is inside of the method boundary - Joshua'
    players = YAML.load_file('player.yaml') 
    players.each {|player, configs|
      configs.each {|name, value|    
        #puts "#{name} -> #{value}"
      }
    }
    puts players['JJ']['cookie_prefix'] + players['JJ']['cookie_end']
  end

  # Method under test from the koans
  def method_with_keyword_arguments(one: 1, two: 'two')
    [one, two]
  end

  # Test from the koan
  def test_keyword_arguments
    assert_equal Array, method_with_keyword_arguments.class
    assert_equal [1, 'two'], method_with_keyword_arguments
    assert_equal ['one','two'], method_with_keyword_arguments(one: 'one')
    assert_equal [1, 2], method_with_keyword_arguments(two: 2)
  end

agent = Mechanize.new 
#agent.methods.each {|method| puts method}
