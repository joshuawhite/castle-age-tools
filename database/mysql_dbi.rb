require "dbi"

# /Library/Ruby/Gems/2.0.0/gems/dbi-0.4.5/lib/dbi.rb:300:in `block in load_driver': Unable to load driver 'Mysql' (underlying error: uninitialized constant DBI::DBD::Mysql) (DBI::InterfaceError)
#      from /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/ruby/2.0.0/monitor.rb:211:in `mon_synchronize'
#      from /Library/Ruby/Gems/2.0.0/gems/dbi-0.4.5/lib/dbi.rb:242:in `load_driver'
#      from /Library/Ruby/Gems/2.0.0/gems/dbi-0.4.5/lib/dbi.rb:160:in `_get_full_driver'
#      from /Library/Ruby/Gems/2.0.0/gems/dbi-0.4.5/lib/dbi.rb:145:in `connect'
#      from mysql_dbi.rb:5:in `<main>'

begin
     # connect to the MySQL server
     dbh = DBI.connect("DBI:Mysql:TESTDB:localhost","testuser","test123")
     # get server version string and display it
     row = dbh.select_one("SELECT VERSION()")
     puts "Server version: " + row[0]
rescue DBI::DatabaseError => e
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
ensure
     # disconnect from server
     dbh.disconnect if dbh
end
