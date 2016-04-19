expect = require('chai').expect
path   = require 'path'

Robot       = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'auth', ->
  robot = {}
  admin_user = {}
  role_user = {}
  anon_user = {}
  adapter = {}

  beforeEach (done) ->
    process.env.HUBOT_AUTH_ADMIN = "1"

    # Create new robot, without http, using mock adapter
    robot = new Robot null, "mock-adapter", false

    robot.adapter.on "connected", ->

      # load the module under test and configure it for the
      # robot. This is in place of external-scripts
      require("../src/auth")(robot)

      admin_user = robot.brain.userForId "1", {
        name: "admin-user"
        room: "#test"
      }

      role_user = robot.brain.userForId "2", {
        name: "role-user"
        room: "#test"
      }

      anon_user = robot.brain.userForId "3", {
        name: "anon-user"
        room: "#test"
      }

      adapter = robot.adapter

    robot.run()

    done()

  afterEach (done) ->
    robot.shutdown()
    done()

  it 'list admin users', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /admin-user/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: who has admin role?")

  it 'list admin users using non-admin user', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /admin-user/i
      done()

    adapter.receive(new TextMessage anon_user, "hubot: who has admin role?")

  it 'anon user fails to set role', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /only admins can assign roles/i
      done()

    adapter.receive(new TextMessage anon_user, "hubot: role-user has demo role")

  it 'admin user successfully sets role', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /role-user has the 'demo' role/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: role-user has demo role")

  it 'admin user successfully sets role in the first-person', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /admin-user has the 'demo' role/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: I have demo role")

  it 'fail to add admin role via command', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /sorry/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: role-user has admin role")

  it 'fail to remove admin role via command', (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).to.match /sorry/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: role-user doesn't have admin role")

  it 'admin user successfully removes role in the first-person', (done) ->
    adapter.receive(new TextMessage admin_user, "hubot: admin-user has demo role")

    adapter.on "reply", (envelope, strings) ->
      if strings[0].match /OK, admin-user has .*demo/i
        return

      expect(strings[0]).to.match /ha(s|ve) the 'demo' role/i
      done()

    adapter.receive(new TextMessage admin_user, "hubot: I don't have demo role")

  it 'successfully list multiple roles of admin user', (done) ->
    adapter.receive(new TextMessage admin_user, "hubot: admin-user has demo role")

    adapter.on "reply", (envelope, strings) ->
      if strings[0].match /OK, admin-user has .*demo/i
        return

      expect(strings[0]).to.match(/following roles: .*admin/)
      expect(strings[0]).to.match(/following roles: .*demo/)
      done()

    adapter.receive(new TextMessage anon_user, "hubot: what roles does admin-user have?")

#by @nick-woodward
 it 'successfully list assigned roles', (done) ->
    adapter.receive(new TextMessage admin_user, "hubot: admin-user has demo role")
    adapter.receive(new TextMessage admin_user, "hubot: anon-user has test role")
    adapter.receive(new TextMessage admin_user, "hubot: admin-user has test role")

    adapter.on "reply", (envelope, strings) ->
      if strings[0].match /OK, .* has .* role/i
        return

      expect(strings[0]).to.match(/following roles .*:.*demo.*test/)
      done()

    adapter.receive(new TextMessage admin_user, "hubot: list assigned roles")
