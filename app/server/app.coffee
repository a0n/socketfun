# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()

exports.actions =
  
  init: (cb) ->
    cb "SocketStream version #{SS.version} is up and running. This message was sent over Socket.IO so everything is working OK."

  authenticate: (params, cb) ->
     @session.authenticate 'user_auth', params, (response) =>
       if response.success
         @session.setUserId(response.user_id)
         cb(@session)
       else
         cb(response)                                                  # sends additional info back to the client

   get_session: (cb) ->
      cb(@session)

   logout: (cb) ->
     @session.user.logout(cb)