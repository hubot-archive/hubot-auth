Helper = require("hubot-test-helper")
helper = new Helper("../src")

expect = require("chai").expect

describe "auth", ->

  beforeEach ->
    process.env.HUBOT_AUTH_ADMIN = "alice"
    @room = helper.createRoom()
    @room.robot.brain.userForId "alice",
      name: "alice"

    @room.robot.brain.userForId "jimmy",
      name: "jimmy"

    @room.robot.brain.userForId "amy",
      name: "amy"

  afterEach ->
    @room.destroy()

  context "<user> has <role> role", ->

    it "admin user successfully sets role", ->
      @room.user.say("alice", "hubot: jimmy has demo role").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: jimmy has demo role"]
          ["hubot", "@alice OK, jimmy has the 'demo' role."]
        ]


    it "admin user successfully sets role in the first-person", ->
      @room.user.say("alice", "hubot: I have demo role").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: I have demo role"]
          ["hubot", "@alice OK, alice has the 'demo' role."]
        ]


    it "fail to add admin role via command", ->
      @room.user.say("alice", "hubot: jimmy has admin role").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: jimmy has admin role"]
          ["hubot", "@alice Sorry, the 'admin' role can only be defined in the HUBOT_AUTH_ADMIN env variable."]
        ]

    it "anon user fails to set role", ->
      @room.user.say("amy", "hubot: jimmy has demo role").then =>
        expect(@room.messages).to.eql [
          ["amy", "hubot: jimmy has demo role"]
          ["hubot", "@amy Sorry, only admins can assign roles."]
        ]

  context "<user> doesn't have <role> role", ->
    it "admin user successfully removes role in the first-person", ->
      @room.user.say("alice", "hubot: alice has demo role").then =>
        @room.user.say("alice", "hubot: I don't have demo role").then =>
          expect(@room.messages).to.eql [
            ["alice", "hubot: alice has demo role"]
            ["hubot", "@alice OK, alice has the 'demo' role."]
            ["alice", "hubot: I don't have demo role"]
            ["hubot", "@alice OK, alice doesn't have the 'demo' role."]
          ]

    it "fail to remove admin role via command", ->
      @room.user.say("alice", "hubot: jimmy doesn't have admin role").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: jimmy doesn't have admin role"]
          ["hubot", "@alice Sorry, the 'admin' role can only be removed from the HUBOT_AUTH_ADMIN env variable."]
        ]

  context "what roles does <user> have", ->
    beforeEach ->
      @room.user.say("alice", "hubot: alice has demo role")

    it "successfully list multiple roles of admin user", ->
      @room.user.say("amy", "hubot: what roles does alice have?").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: alice has demo role"]
          ["hubot", "@alice OK, alice has the 'demo' role."]
          ["amy", "hubot: what roles does alice have?"]
          ["hubot", "@amy alice has the following roles: admin, demo."]
        ]

  context "who has <role> role", ->
    it "list admin users", ->
      @room.user.say("alice", "hubot: who has admin role?").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: who has admin role?"]
          ["hubot", "@alice The following people have the 'admin' role: alice"]
        ]

    it "list admin users using non-admin user", ->
      @room.user.say("amy", "hubot: who has admin role?").then =>
        expect(@room.messages).to.eql [
          ["amy", "hubot: who has admin role?"]
          ["hubot", "@amy The following people have the 'admin' role: alice"]
        ]

  context "list assigned roles", ->
    beforeEach ->
        @room.user.say("alice", "hubot: alice has demo role").then =>
          @room.user.say("alice", "hubot: amy has test role").then =>
            @room.user.say "alice", "hubot: alice has test role"

    it "successfully list assigned roles", ->
        @room.user.say("alice", "hubot: list assigned roles").then =>
          expect(@room.messages).to.eql [
            ["alice", "hubot: alice has demo role"]
            ["hubot", "@alice OK, alice has the 'demo' role."]
            ["alice", "hubot: amy has test role"]
            ["hubot", "@alice OK, amy has the 'test' role."]
            ["alice", "hubot: alice has test role"]
            ["hubot", "@alice OK, alice has the 'test' role."]
            ["alice", "hubot: list assigned roles"]
            ["hubot", "@alice The following roles are available: demo, test"]
          ]
