# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()
  
exports.actions =
  find_by_email: (email, cb) ->
    R.get("username:" + email, (err, data)->
      cb data
    )

  create: (params, cb) ->
    console.log(params)
    uuid = generate_uuid()
    R.exists("username:" + params.email, (err, data) ->
      if (data == 0)
        R.set("username:" + params.email, uuid, (err) ->
          R.set("user_id:" + uuid + ".password", params.password, (err) ->
              
          )
        )
      else 
        cb {error: true, reason: 'User exists.'}
    )
    
  
  