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
