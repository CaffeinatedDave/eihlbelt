require 'Date'

prevHolder = "None"
currentHolder = ARGV[0] || "Nottingham"

data = {}

def makeDefaultStats()
  return {
    "gamesSinceChallenged" => 0,
    "failedAttempts" => 0,
    "streak" => 0,
    "titles" => []
  }
end

streak = 0
streakStart = "Season 2010-11 Champions"
data[currentHolder] = makeDefaultStats

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
    data[win] = makeDefaultStats
  end
  if data[lose] == nil
    data[lose] = makeDefaultStats
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
         "to" => win,
         "from" => prevHolder
       }
       data[lose]["titles"] << oldReign

#       puts "#{date}: #{win} is the new champion, defeating #{lose} #{wscore} to #{lscore} after #{streak} games"
       streakStart = dateStr
       prevHolder = currentHolder
       currentHolder = win
       streak = 1
     else
       streak += 1
       data[lose]["failedAttempts"] += 1
#       if ot == nil
#         puts "#{date}: #{currentHolder} is still the champion, defeating #{lose} #{wscore} to #{lscore}. Streak of #{streak}"
#       else
#         puts "#{date}: #{currentHolder} is still the champion, despite losing #{wscore} - #{lscore} to #{win} AOT. Streak of #{streak}"
#       end
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
  "from" => prevHolder
}
data[currentHolder]["titles"] << currentReign

data.sort.each do |k, v|
  puts k
  teamGames = 0
  v["titles"].each do |t|
    tFormated = "#{t['start']} (from #{t['from']}) - #{t['end']}: #{t['streak']} games"
    if t['to'] != nil
      tFormated += " (to #{t['to']})"
    end
    puts " - #{tFormated}"
    teamGames += t['streak']
  end
  puts "#{v['titles'].length} Time Champion"
  puts "#{teamGames} Total Games As Champion"
  puts "Average reign: #{teamGames / v['titles'].length} Games"
  puts "#{v['gamesSinceChallenged']} Games since challenged for title"

  titleGames = v['failedAttempts'] + teamGames
  challengePercent = (v['titles'].length * 100.0) / (v['titles'].length + v['failedAttempts'] + 0.0)
  titlePercent = (teamGames * 100.0) / (titleGames + 0.0)

  puts "#{v['titles'].length} : #{v['titles'].length + v['failedAttempts']} Win rating when challenging (#{challengePercent}%)"
  puts "#{teamGames} : #{titleGames} Win rating in title games (#{titlePercent}%)"
  puts "-----"
end
