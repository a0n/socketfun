exports.authenticate = (params, cb) ->
  get_user_id_for_email(params.email, (uid) ->
    if uid #if user id exists, conti
      #get password
      get_user_password_for_uid(uid, (password) ->
        if (password && password == params.password)
          cb({success: true, user_id: uid})
        else
          cb({success: false, error_reason: "Password is wrong!"})
      )
    else
      cb({success: false, error_reason: "User does not exist!"})
  )
 

get_user_id_for_email = (email, cb) ->
  R.get("username:" + email, (err, uid) ->
    cb uid 
  )
  
get_user_password_for_uid = (uid, cb) ->
  R.get("user_id:" + uid + ".password", (err, password) -> 
    cb password
  )