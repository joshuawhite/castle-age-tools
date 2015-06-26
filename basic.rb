require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-a", "--[no-]attack", "Search for attack essence") do |a|
    options[:attack] = a
  end

  opts.on("-d", "--[no-]damage", "Search for damage essence") do |d|
    options[:damage] = d
  end

  opts.on("-e", "--[no-]defense", "Search for defense essence") do |e|
    options[:defense] = e
  end

  opts.on("-cCOOKIE", "--cookie=COOKIE", "End of login cookie") do |c|
    options[:cookie_end] = c
  end

end.parse!

p options[:attack]

if (options[:damage])
	puts 'Damage!'
end
if (options[:defense])
	puts 'Defense!'
end
if (options[:cookie_end])
	puts options[:cookie_end]
end
