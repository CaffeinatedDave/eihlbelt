Dir["./results/*"].sort.each do |file|
  linearr = []
  File.open(file).each do |line|
    linearr << line
  end

  season = file.split('/')[-1]

  stage = nil
  event = ""
  stage = 0
  eventList = []

  date = ""
  home = ""
  away = ""
  ot = false
  hscore = 0
  ascore = 0


  linearr.each do |line|
    line.strip!
    if stage == 0 and /\d\d\.\d\d/ =~ line
      date = line
      stage = 1
    elsif stage == 1 and /AOT/ =~ line
      ot = true
    elsif stage == 1 and /Pen/ =~ line
      ot = true
    elsif stage == 1 and /^[A-Za-z\ ]*$/ =~ line
      home = line
      stage = 2
    elsif stage == 2 and /^[A-Za-z\ ]*$/ =~ line
      away = line
      stage = 3
    elsif stage == 3
      hscore = line  
      stage = 4
    elsif stage == 4
      ascore = line

      event = "#{season}: #{date}  "

      home = fullName(home)
      away = fullName(away)

      event += if hscore > ascore 
        "#{home} (#{hscore}) def #{away} (#{ascore})"
      else 
        "#{away} (#{ascore}) def #{home} (#{hscore})"
      end

      event += " (AOT)" if ot 

      eventList << event

      date = ""
      home = ""
      away = ""
      ot = false
      hscore = 0
      ascore = 0
     
      stage = 0
    end
  end

  eventList.reverse.each do |event|
    puts event
  end

end
