# Description
#   Assign roles to users and restrict command access in other scripts.
#
# Configuration:
#   HUBOT_AUTH_ADMIN      - A comma separate list of user IDs
#   HUBOT_AUTH_ADMIN_ONLY - If set (to anything), only admins can add and remove people from roles
#
# Commands:
#   hubot <user> has <role> role - Assigns a role to a user
#   hubot <user> doesn't have <role> role - Removes a role from a user
#   hubot what role does <user> have - Find out what roles are assigned to a specific user
#   hubot what role do I have - Find out what roles you have
#   hubot who has admin role - Find out who's an admin and can assign roles
#   hubot who has <role> role - Find out who has the given role
#
# Notes:
#   * Call the method: robot.auth.hasRole(msg.envelope.user,'<role>')
#   * returns bool true or false
#
#   * the 'admin' role can only be assigned through the environment variable
#   * roles are all transformed to lower case
#
#   * The script assumes that user IDs will be unique on the service end as to
#     correctly identify a user. Names were insecure as a user could impersonate
#     a user

config =
  admin_list: process.env.HUBOT_AUTH_ADMIN
  admin_only: process.env.HUBOT_AUTH_ADMIN_ONLY

module.exports = (robot) ->

  unless config.admin_list?
    robot.logger.warning 'The HUBOT_AUTH_ADMIN environment variable not set'

  if config.admin_list?
    admins = config.admin_list.split ','
  else
    admins = []

  class Auth
    hasRole: (user, roles) ->
      user = robot.brain.userForId(user.id)
      userRoles = @userRoles(user) if user?
      if user? and userRoles?
        roles = [roles] if typeof roles is 'string'
        for role in roles
	  return true if role in userRoles
      return false

    usersWithRole: (role) ->
      users = []
      for own key, user of robot.brain.data.users
	if @hasRole(user, role)
          users.push(user)
      users

    userRoles: (user) ->
      user = robot.brain.userForId(user.id)
      roles = []
      if user? and user.id.toString() in admins
        roles.push('admin')
      if user.roles?
        roles.concat user.roles
      roles

  robot.auth = new Auth

  robot.respond /@?(.+) has (["'\w: -_]+) role/i, (msg) ->
    if config.admin_only? and msg.message.user.id not in admins
      msg.reply "Sorry, only admins can assign roles."
    else
      name    = msg.match[1].trim()
      newRole = msg.match[2].trim().toLowerCase()

      unless name.toLowerCase() in ['', 'who', 'what', 'where', 'when', 'why']
        user = robot.brain.userForName(name)
        return msg.reply "#{name} does not exist" unless user?
        user.roles or= []

        if newRole in user.roles
          msg.reply "#{name} already has the '#{newRole}' role."
        else
          if newRole is 'admin'
            msg.reply "Sorry, the 'admin' role can only be defined in the HUBOT_AUTH_ADMIN env variable."
          else
            myRoles = msg.message.user.roles or []
            if msg.message.user.id.toString() in admins
              user.roles.push(newRole)
              msg.reply "OK, #{name} has the '#{newRole}' role."

  robot.respond /@?(.+) does(?:n't| not) have (["'\w: -_]+) role/i, (msg) ->
    if config.admin_only? and msg.message.user.id not in admins
      msg.reply "Sorry, only admins can remove roles."
    else
      name    = msg.match[1].trim()
      newRole = msg.match[2].trim().toLowerCase()

      unless name.toLowerCase() in ['', 'who', 'what', 'where', 'when', 'why']
        user = robot.brain.userForName(name)
        return msg.reply "#{name} does not exist" unless user?
        user.roles or= []

        if newRole is 'admin'
          msg.reply "Sorry, the 'admin' role can only be removed from the HUBOT_AUTH_ADMIN env variable."
        else
          myRoles = msg.message.user.roles or []
          if msg.message.user.id.toString() in admins
            user.roles = (role for role in user.roles when role isnt newRole)
            msg.reply "OK, #{name} doesn't have the '#{newRole}' role."

  robot.respond /(?:what roles? do(?:es)?) @?(.+) have\?*$/i, (msg) ->
    name = msg.match[1].trim()
    if name.toLowerCase() is 'i' then name = msg.message.user.name
    user = robot.brain.userForName(name)
    return msg.reply "#{name} does not exist" unless user?
    userRoles = robot.auth.userRoles(user)

    if userRoles.length == 0
      msg.reply "#{name} has no roles."
    else
      msg.reply "#{name} has the following roles: #{userRoles.join(', ')}."

  robot.respond /who has (["'\w: -_]+) role\?*$/i, (msg) ->
    role = msg.match[1]
    userNames = []
    users = robot.brain.users()
    for own id, user of users
      userRoles = robot.auth.userRoles(user)
      user.roles ?= []
      userNames.push user.name if role in userRoles

    if userNames.length > 0
      msg.reply "The following people have the '#{role}' role: #{userNames.join(', ')}"
    else
      msg.reply "There are no people that have the '#{role}' role."
