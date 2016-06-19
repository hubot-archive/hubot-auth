# Hubot: hubot-auth

[![Build Status](https://travis-ci.org/hubot-scripts/hubot-auth.svg?branch=master)](https://travis-ci.org/hubot-scripts/hubot-auth)

Assign roles to users and restrict command access in other scripts.

See [`src/auth.coffee`](src/auth.coffee) for full documentation.

## Installation

Add **hubot-auth** to your `package.json` file:

```
npm install --save hubot-auth
```

Add **hubot-auth** to your `external-scripts.json`:

```json
["hubot-auth"]
```

Run `npm install`

## Sample Interaction

```
user1>> hubot user2 has jester role
hubot>> OK, user2 has the jester role.
```

## HUBOT_AUTH_ROLES

This can be used to give a default set of roles and **must** be used to set the admin role.

```sh
HUBOT_AUTH_ROLES="admin=U12345678 mod=U87654321,U67856745"
```
