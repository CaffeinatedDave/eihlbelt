require 'Date'

prevHolder = "None"
currentHolder = ARGV[0] || "Nottingham"
htmlMode = ARGV.map{|f| f == "-h"}.any?

data = {}

def fullName(str)
  teams = {
    "Belfast" => "Belfast Giants",
    "Cardiff" => "Cardiff Devils",
    "Coventry" => "Coventry Blaze",
    "Dundee" => "Dundee Stars",
    "Fife" => "Fife Flyers",
    "Glasgow" => "Glasgow Clan",
    "Guildford" => "Guildford Flames",
    "Manchester" => "Manchester Storm",
    "Nottingham" => "Nottingham Panthers",
    "Sheffield" => "Sheffield Steelers",
    "Hull" => "Hull Stingrays",
    "Edinburgh" => "Edinburgh Capitals",
    "MiltonKeynes" => "Milton Keynes Lightning"
  }

  if teams[str] == nil
    return str
  else
    return teams[str]
  end
end

def makeDefaultStats(str)
  return {
    "teamName" => fullName(str),
    "gamesSinceChallenged" => 0,
    "totalFailedAttempts" => 0,
    "failedAttempts" => [],
    "streak" => 0,
    "titles" => []
  }
end

streak = 0
streakStart = "Season 2010-11 Champions"
data[currentHolder] = makeDefaultStats(currentHolder)

File.open("gameData").each do |game|
  dateEnc, score = game.split("  ")

  season, date, _ = dateEnc.split(" ")

  seasonStart = season[0..3]
  seasonEnd = season[0..1] + season[4..5]

  day, monthIdx, _ = date.split(".")
  month = Date::MONTHNAMES[monthIdx.to_i]

  dateStr = "#{day} #{month} "
  if monthIdx.to_i > 7
    dateStr += seasonStart
  else
    dateStr += seasonEnd
  end

  win, wscore, _, lose, lscore, ot = score.split(" ")

  # Make sure our teams exist for stats!
  if data[win] == nil
    data[win] = makeDefaultStats(win)
  end
  if data[lose] == nil
    data[lose] = makeDefaultStats(lose)
  end

  wscore = wscore[1..-2]
  lscore = lscore[1..-2]

  if win == currentHolder or lose == currentHolder
     data[win]["gamesSinceChallenged"] = 0
     data[lose]["gamesSinceChallenged"] = 0

     challenger = if (win == currentHolder)
       lose
     else
       win
     end

#     puts "Matchup: #{currentHolder} (C) vs #{challenger}"

     if ot == nil and lose == currentHolder

       oldReign = {
         "start" => streakStart,
         "end" => dateStr,
         "streak" => streak,
         "to" => fullName(win),
         "from" => fullName(prevHolder)
       }
       data[lose]["titles"] << oldReign

       puts "#{dateStr}: #{win} is the new champion, defeating #{lose} #{wscore} to #{lscore} after #{streak} games"
       streakStart = dateStr
       prevHolder = currentHolder
       currentHolder = win
       data[win]["failedAttempts"] = []
       streak = 1
     else
       streak += 1
       if ot == nil
         puts "#{dateStr}: #{currentHolder} is still the champion, defeating #{lose} #{wscore} to #{lscore}. Streak of #{streak}"
         data[lose]["totalFailedAttempts"] += 1
         data[lose]["failedAttempts"] << game
       else
         puts "#{dateStr}: #{currentHolder} is still the champion, despite losing #{wscore} - #{lscore} to #{win} AOT. Streak of #{streak}"
         data[win]["totalFailedAttempts"] += 1
         data[win]["failedAttempts"] << game
       end
     end
  else
    data[win]["gamesSinceChallenged"] += 1
    data[win]["streak"] += 1
    data[lose]["gamesSinceChallenged"] += 1
    data[lose]["streak"] = 0
  end
end

# Don't forget current champion!
currentReign = {
  "start" => streakStart,
  "end" => "current",
  "streak" => streak,
  "to" => nil,
  "from" => fullName(prevHolder)
}
data[currentHolder]["titles"] << currentReign

data.sort.each do |k, v|
  if htmlMode 
    puts "<h4>#{v['teamName']}</h4>"
    puts "<p>#{v['titles'].length} Time Champions</p>"
    puts "<table>"
    puts "  <tr><th>Start Date</th><th>Previous Holders</th><th>End Date</th><th>Duration</th></tr>"
  else
    puts k
    puts "#{v['titles'].length} Time Champions"
  end
  teamGames = 0
  v["titles"].each do |t|
    tFormated = "#{t['start']} (from #{t['from']}) - #{t['end']}: #{t['streak']} games"
    hFormated = "  <tr><td>#{t['start']}</td><td>#{t['from']}</td><td>#{t['end']}</td><td>#{t['streak']} games</td></tr>"
    if t['to'] != nil
      tFormated += " (to #{t['to']})"
    end
    if htmlMode 
      puts "#{hFormated}"
    else
      puts " - #{tFormated}"
    end
    teamGames += t['streak']
  end
  titleGames = v['totalFailedAttempts'] + teamGames
  challengePercent = (v['titles'].length * 100.0) / (v['titles'].length + v['totalFailedAttempts'] + 0.0)
  titlePercent = (teamGames * 100.0) / (titleGames + 0.0)

  if htmlMode 
    puts "</table>"
  else

    puts "#{teamGames} Total Games As Champion"
    puts "Average reign: #{teamGames / v['titles'].length} Games"
    puts "#{v['gamesSinceChallenged']} Games since challenged for title"
    puts "#{v['failedAttempts'].length} failed title challenges since last reign:"
    v['failedAttempts'].each do |g|
      puts g.to_s
    end

    puts "#{v['titles'].length} : #{v['titles'].length + v['totalFailedAttempts']} Win rating when challenging (#{challengePercent}%)"
    puts "#{teamGames} : #{titleGames} Win rating in title games (#{titlePercent}%)"
    puts "-----"
  end
end
