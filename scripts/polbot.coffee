# Description
#   Vote on stuff!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   pollbot open item1, item2, item3, ...
#   pollbot upvote for N - where N is the choice number or the choice name
#   pollbot choices
#   pollbot tally - shows current votes
#   pollbot close
#
# Notes:
#   None
# 
# TODO:
#   Add timer function
#   Allow only user who opened the polls to close them
#
# Original Author:
#   antonishen

module.exports = (robot) ->
  robot.voting = {}

  robot.respond /help/i, (msg) ->
    msg.send "```pollbot open item1, item2, ... -- Start a poll with choices
    pollbot upvote (for) n -- where n is choice, for is optional
    pollbot choices -- shows current choices
    pollbot tally -- shows current votes
    pollbot close -- end poll
    ```"

  robot.respond /open (.+)$/i, (msg) ->

    if robot.voting.votes?
      msg.send "```polls are currently open, try once this election cycle is done```"
      sendChoices(msg)
    else
      robot.voting.votes = {}
      createChoices msg.match[1]

      msg.send "```Polls are open:\n>pollbot upvote [choice]```"
      sendChoices(msg)

  robot.respond /close/i, (msg) ->
    if robot.voting.votes?
      console.log robot.voting.votes

      results = tallyVotes()

      response = "@here ```TIME'S UP: "
      for choice, index in robot.voting.choices
        response += "#{choice}: #{results[index]}```"

      msg.send response

      delete robot.voting.votes
      delete robot.voting.choices
    else
      msg.send "```bruh, polls are closed right now```"


  robot.respond /choices/i, (msg) ->
    sendChoices(msg)

  robot.respond /tally/i, (msg) ->
    results = tallyVotes()
    sendChoices(msg, results)

  robot.respond /upvote (for )?(.+)$/i, (msg) ->
    choice = null

    re = /\d{1,2}$/i
    if re.test(msg.match[2])
      choice = parseInt msg.match[2], 10
    else
      choice = robot.voting.choices.indexOf msg.match[2]

    console.log choice

    sender = robot.brain.usersForFuzzyName(msg.message.user['name'])[0].name

    if validChoice choice
      robot.voting.votes[sender] = choice
      msg.send "```#{sender} likes #{robot.voting.choices[choice]}```"
    else
      msg.send "```#{sender}: check the choices and try again```"

  createChoices = (rawChoices) ->
    robot.voting.choices = rawChoices.split(/, /)

  sendChoices = (msg, results = null) ->

    if robot.voting.choices?
      response = ""
      for choice, index in robot.voting.choices
        response += "```#{choice} - #{index}"
        if results?
          response += " -- currently at: #{results[index]}```"
        response += "\n" unless index == robot.voting.choices.length - 1
    else
      msg.send "sorry, polls are closed"

    msg.send response

  validChoice = (choice) ->
    numChoices = robot.voting.choices.length - 1
    0 <= choice <= numChoices

  tallyVotes = () ->
    results = (0 for choice in robot.voting.choices)

    voters = Object.keys robot.voting.votes
    for voter in voters
      choice = robot.voting.votes[voter]
      results[choice] += 1

    results