# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()
  
generate_topic_list_position = (next_topic_id, prev_topic_id) ->
  if next_topic_id
    return {pivot: "BEFORE", pivot_topic_id: next_topic_id}
  else if prev_topic_id
    return {pivot: "AFTER", pivot_topic_id: prev_topic_id}
  else
    return null
    
insert_topic_in_user_list = (topic_id, user_id, position, options, cb) ->
  multi = R.multi()
  if options.move
    console.log("moving topic")
    multi.lrem "user_id:" + user_id + ".topics", "1", topic_id
  if position
    console.log("inserting at certain position")
    multi.linsert "user_id:" + user_id + ".topics", position.pivot, position.pivot_topic_id, topic_id
  else
    console.log("inserting at the end of the list")
    R.rpush "user_id:" + user_id + ".topics", topic_id
      
  multi.exec( (err, replies) ->
    if err
      cb false
    else
      cb true
  )


exports.actions =
  find: (uuid, cb) ->
    R.hgetall("topic_id:"+uuid+".attributes", (err, topic)->
      cb topic
    )

  create: (params, cb) ->
    console.log(params)
    uuid = generate_uuid()
    current_user_id = @session.user_id
    attributes = {name: params.name, user_id: current_user_id, id: uuid}
    
    
    position = generate_topic_list_position(params["next_topic_id"], params["prev_topic_id"])
    insert_topic_in_user_list(uuid, current_user_id, position, {move: false}, (success)->
      if success == false
        cb false
      else
        R.hmset "topic_id:" + uuid + ".attributes", attributes, (err, status) ->
          if err
            cb false
          else
            if position
              attributes["position"] = position
            SS.publish.broadcast 'newTopic', attributes
            
            cb attributes
    )
          # Broadcast the message to everyone
    
      
  update: (params, cb) ->
    console.log params
    topic_id = params.id
    next_topic_id = params["next_topic_id"]
    prev_topic_id = params["prev_topic_id"]
    delete params["next_topic_id"] #lets not save the next_topic_id
    delete params["prev_topic_id"] #lets not save the next_topic_id
    console.log params
    console.log "UPDATE!!!!"
    delete params["id"] # the id is already there
    delete params["user_id"] # lets not change the user of the topic
    current_user_id = @session.user_id
    console.log(params)
    R.hget("topic_id:" + topic_id + ".attributes", "user_id", (err, topic_user_id) ->
      console.log(topic_user_id)
      if current_user_id == topic_user_id
        console.log("CHANGING TOPIC!")
        position = generate_topic_list_position(next_topic_id, prev_topic_id)
        if position
          insert_topic_in_user_list(topic_id, current_user_id, position, {move: true}, (status)->
            
          )
        
        R.hmset("topic_id:" + topic_id + ".attributes", params, (status) ->
          params["id"] = topic_id
          if position
            params["position"] = position
          SS.publish.broadcast 'updateTopic', params
          cb params
        )
      else
        cb false
    )
 
  delete: (params, cb) ->
    topic_id = params
    
    current_user_id = @session.user_id
    R.hget("topic_id:" + topic_id + ".attributes", "user_id", (err, topic_user_id) ->
      console.log(topic_user_id)
      if current_user_id == topic_user_id
        R.hkeys("topic_id:" + topic_id + ".attributes", (err, keys) ->
          console.log(keys)
          multi = R.multi()
          multi.del("topic_id:" + topic_id + ".attributes", keys)
          multi.lrem("user_id:" + current_user_id + ".topics", 0, topic_id)
          multi.exec( (err, replies) ->
            if err
              cb false
            else
              SS.publish.broadcast 'deleteTopic', topic_id
              cb true
          )
        )
      else
        cb false
    )          
    
  all: (options, cb) ->
    console.log "path!!"
    console.log "user_id:"+ @session.user_id + ".topics"
    R.lrange("user_id:"+ @session.user_id + ".topics", -100, 1000, (err, topic_ids) ->
      topics = []
      multi = R.multi()
      console.log "asdasdasdasdasd"
      console.log topic_ids
      for i in [0..topic_ids.length]
        if topic_ids[i]
          multi.hgetall("topic_id:"+topic_ids[i]+".attributes")

      multi.exec( (err, replies) ->
        console.log replies.length
        if replies.length > 0
          console.log replies
          cb replies
        else
          cb null
      )
    )