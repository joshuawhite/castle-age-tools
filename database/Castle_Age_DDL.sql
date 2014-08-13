# Castle Age Database Definition

# DROP SCRIPT
DROP TABLE CA_Joshua;
DROP TABLE Guild_Member;
DROP TABLE Guild;
DROP TABLE Char_Achieve;
DROP TABLE Achievement;
DROP TABLE Stats;
DROP TABLE CA_Character;

# Base character table (minimal info from guild listing)
#
# CASUSER - Castle Age internal ID
# NAME - Player name
# LEVEL - Player current level
# CHAR_CLASS - Player current class
# UPDATED - Last updated timestamp
CREATE TABLE CA_Character (casuser BIGINT UNSIGNED NOT NULL, PRIMARY KEY (casuser), name VARCHAR(50), level INT, char_class VARCHAR(20), updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

# Owned character stats table (stuff from the keep page)
#
# CASUSER - Castle Age internal ID (foriegn key to CA_Character)
# ENERGY, STAMINA, ATTACK, DEFENSE, HEALTH - Normal player stats
# ARMY, FAVOR_POINTS, GUILD_COINS - Collected Player stats
# UPDATED - Last updated timestamp
CREATE TABLE Stats (casuser BIGINT REFERENCES CA_Character(casuser) ON DELETE CASCADE, PRIMARY KEY (casuser), energy INT, stamina INT, attack INT, defense INT, health INT, army INT, favor_points INT, guild_coins INT, updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

# Castle Age Achievements (Master data from CA)
#
# ACHIEVE_NAME - Name of acheivement to collect
# THRESHHOLD - Number of completions to trigger achievement
CREATE TABLE Achievement (achieve_name VARCHAR(50), PRIMARY KEY (achieve_name), threshhold INT);

# Character Achievements
#
# CASUSER - Castle Age internal ID (foriegn key to CA_Character)
# ACHIEVE_NAME - Name of acheivement to collect (foriegn key to Achievemnt)
# ACHIEVE_VALUE - Number of completions of achievement condition
# UPDATED - Last updated timestamp
CREATE TABLE Char_Achieve (casuser BIGINT REFERENCES CA_Character(casuser) ON DELETE CASCADE, achieve_name VARCHAR(50) REFERENCES Achievement(achieve_name) ON DELETE CASCADE, achieve_value INT, updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

# Base guild table
#
# GUILD_ID - Castle Age internal guild ID
# GUILD_NAME - Name of guild
CREATE TABLE Guild (guild_id VARCHAR(30) NOT NULL, PRIMARY KEY (guild_id), guild_name VARCHAR(50));

# A guild member and their battle location
#
# GUILD_ID - Castle Age internal guild ID (foriegn key to CA_Character)
# CASUSER - Castle Age internal ID (foriegn key to CA_Character)
# TOWER_NUMBER - Not sure if this was supposed to be (1-4) for the N/S/E/W or 1-100 for the location
# UPDATED - Last updated timestamp
CREATE TABLE Guild_Member (guild_id VARCHAR(30) REFERENCES Guild(guild_id) ON DELETE CASCADE, casuser BIGINT REFERENCES CA_Character(casuser) ON DELETE CASCADE, tower_number INT, updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

# Data table for cookies for each of my characters - this should loosely match the Stats table
#
# CASUSER - Castle Age internal ID (foriegn key to CA_Character)
# COOKIE - Login cookie value
# UPDATED - Last updated timestamp
CREATE TABLE CA_Joshua (casuser BIGINT UNSIGNED NOT NULL, PRIMARY KEY (casuser), cookie VARCHAR(200), updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
