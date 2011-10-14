# Server-side Code
# Server-side Code
rbytes = require('rbytes')

generate_uuid =->
  return rbytes.randomBytes(16).toHex()


check_if_user_exists = (email, cb) ->
  R.exists "username:" + email, (err, data) ->
    if (err) 
      cb ({error: true, reasons: ["Database connection error"]})
    else
      if (data == 0)
        cb false
      else
        cb true

exports.actions =
  exists: (email, cb) ->
    check_if_user_exists email, (user_exists) ->
      if user_exists
        cb true
      else
        cb {error: true, reasons: ['User does not exist.']}

  find_id_by_email: (email, cb) ->
    R.get "username:" + email, (err, data)->
      if (err)
        cb ({error: true, reasons: ["Database connection error"]})
      else
        cb data
    
  create: (params, cb) ->
    check_if_user_exists params.email, (user_exists) ->
      if !user_exists
        R.set "username:" + params.email, uuid, (err) ->
          R.set "user_id:" + uuid + ".password", params.password, (err) ->
      else
        cb {error: true, reasons: ['User exists.']}