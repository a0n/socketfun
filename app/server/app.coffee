# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()

exports.actions =
  authenticate: (params, cb) ->
     @session.authenticate 'user_auth', params, (response) =>
       if response.success
         @session.setUserId(response.user_id)
         
         SS.server.topic.all((topics)->
            for topic in [0..topics.length - 1]
              @session.channel.subscribe('topic_id:'+topic.id)
         )
         
         cb(@session)
       else
         cb(response)                                                  # sends additional info back to the client

   get_session: (cb) ->
      cb(@session)
      
   get_channel_list: (cb) ->
     cb @session.channel.list()   

   echo: (params, cb) ->
     cb params

   logout: (cb) ->
     @session.user.logout(cb)