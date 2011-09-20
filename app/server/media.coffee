# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()

exports.actions =
  #find: (uuid, cb) ->
   # R.hgetall("topic_id:"+uuid+".attributes")
 all: (options, cb) ->
   topic_id = options.topic_id
   if topic_id
     R.lrange("topic_id:"+ topic_id + ".medias", -100, 100, (err, medias_ids) ->
       topics = []
       multi = R.multi()
       console.log medias_ids
       for i in [0..medias_ids.length]
         console.log i
         multi.hgetall("media_id:"+medias_ids[i]+".attributes")

       multi.exec( (err, replies) ->
           cb replies
       )
     )
   
  create: (params, cb) ->
    uuid = generate_uuid()
    params.id = uuid
    params.user_id = @session.user_id
    SS.publish.broadcast 'newMedia', params      # Broadcast the message to everyone
    
    R.lpush "topic_id:" + params.topic_id + ".medias", uuid
    R.hmset "media_id:" + uuid + ".attributes", params
    cb params
  