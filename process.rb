currentHolder = ARGV[0]

data = {}

def makeDefaultStats()
  return {
    "gwc" => 0,
    "fa" => 0,
    "streak" => 0,
    "titles" => []
  }
end

streak = 0
streakStart = "000"
data[currentHolder] = makeDefaultStats

File.open("gameData").each do |game|
  date, score = game.split("  ")

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
     data[win]["gwc"] = 0
     data[lose]["gwc"] = 0
     
     challenger = if (win == currentHolder)
       lose
     else
       win
     end

#     puts "Matchup: #{currentHolder} (C) vs #{challenger}"

     if ot == nil and lose == currentHolder

       oldReign = {
         "start" => streakStart,
         "end" => date,
         "streak" => streak
       }
       data[lose]["titles"] << oldReign

#       puts "#{date}: #{win} is the new champion, defeating #{lose} #{wscore} to #{lscore} after #{streak} games"
       streakStart = date
       currentHolder = win
       streak = 1
     else
       streak += 1
#       if ot == nil
#         puts "#{date}: #{currentHolder} is still the champion, defeating #{lose} #{wscore} to #{lscore}. Streak of #{streak}"
#       else
#         puts "#{date}: #{currentHolder} is still the champion, despite losing #{wscore} - #{lscore} to #{win} AOT. Streak of #{streak}"
#       end
     end
  else
    data[win]["gwc"] += 1
    data[win]["streak"] += 1
    data[lose]["gwc"] += 1
    data[lose]["streak"] = 0
  end
end

data.sort.each do |k, v|
  puts k
  teamGames = 0
  data[k]["titles"].each do |t|
    puts "  #{t['start']} - #{t['end']}: #{t['streak']} games"
    teamGames += t['streak']
  end
  puts "#{data[k]['titles'].length} Time Champion"
  puts "#{teamGames} Total Games As Champion"
  puts "Average reign: #{teamGames / data[k]['titles'].length} Games"
  puts "-----"
end
