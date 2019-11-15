EIHL Championship Belt
======================

Results up to date as of 2019/11/15

To Run
------

Run `ruby parse.rb > gameData` to output all fixtures into a useable format, into a file called `gameData`.

Run `ruby process.rb <TeamName>` to process the current champion, based on the starting champion of <TeamName> (I've used Nottingham for most things, as they won the league the previous year)


Data
-----

Season scores come from https://www.flashscore.co.uk/hockey/united-kingdom/elite-league/results/ (and relevant previous year's data). It's literally a copy/paste from their pages, and so is the following format:

```
08.12. 18:00  | - Date/Time of match
Pen           | - Optional indicator if match was After OT (AOT) or Penalties (Pen)
Cardiff       | - Home Team
Dundee        | - Away Team
5             | - Home final score
4             | - Away final score
2             | - Home Period 1 goals
1             | - Away Period 1 goals
2             | - Home Period 2 goals
1             | - Away Period 2 goals
0             | - Home Period 3 goals
2             | - Away Period 3 goals
0             | - Home OT Period goals (if applicable)
0             | - Away OT Period goals (if applicable)
2             | - Home Penalty goals (if applicable)
1             | - Away Penalty goals (if applicable)
```

Scores contain only season (and maybe challenge cup? FS doesn't distinguish) results. Playoffs are ignored due to there not being an even number of matchups between teams.
