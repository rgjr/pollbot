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
#   polbot open item1, item2, item3, ...
#   polbot upvote for N - where N is the choice number or the choice name
#   polbot choices
#   polbot show votes - shows current votes
#   polbot close
#
# Notes:
#   None
#
# Original Author:
#   antonishen

module.exports = (robot) ->
  robot.voting = {}

  robot.respond /open (.+)$/i, (msg) ->

    if robot.voting.votes?
      msg.send "POLLS ARE ALREADY OPEN, TRY AGAIN NEXT ELECTION CYCLE"
      sendChoices(msg)
    else
      robot.voting.votes = {}
      createChoices msg.match[1]

      msg.send "POLLS ARE NOW OPEN, ROCK THE VOTE:"
      sendChoices(msg)

  robot.respond /end/i, (msg) ->
    if robot.voting.votes?
      console.log robot.voting.votes

      results = tallyVotes()

      response = "TIME'S UP: "
      for choice, index in robot.voting.choices
        response += "\n option #{choice}: #{results[index]}"

      msg.send response

      delete robot.voting.votes
      delete robot.voting.choices
    else
      msg.send "BRUH, POLLS ARE CLOSED"


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
      msg.send "#{sender} likes #{robot.voting.choices[choice]}"
    else
      msg.send "#{sender}: CHECK THE CHOICES, TRY AGAIN"

  createChoices = (rawChoices) ->
    robot.voting.choices = rawChoices.split(/, /)

  sendChoices = (msg, results = null) ->

    if robot.voting.choices?
      response = ""
      for choice, index in robot.voting.choices
        response += "\t option #{index+1}: #{choice}"
        if results?
          response += " -- sitting at: #{results[index]}"
        response += "\n" unless index == robot.voting.choices.length - 1
    else
      msg.send "NOPE, POLLS CLOSED"

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