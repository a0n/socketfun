# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Make a call to the server to retrieve a message
  SS.client.topic.load()
  SS.client.media.load()
 
  window.AppRouter = Backbone.Router.extend({
    routes: {
        ""  : "start_app_if_not_started",
        "topics/:id": "topics",
        "logout" : "logout",
        "login" : "login"
    },

    logout: -> 
      self = this
      SS.server.app.logout((response) ->
        if response == true
          $("body").removeClass("booted")
          window.AppRouter.navigate("login", true);
      )
    login: ->
      SS.client.user_session.init()
    start_app_if_not_started: (topic_id) ->
      if !$("body").hasClass("booted")

        SS.server.app.get_session((session) ->
          if !session.user_id           
            window.AppRouter.navigate("login", true); 
          else  
            options = {active_topic_id: topic_id, user_id: session.user_id}
            window.current_user = session
            SS.client.media.load()
            SS.client.topic.init(options)
            
            $("body").addClass("booted")
        )

    topics: (topic_id) ->
      this.start_app_if_not_started(topic_id)
  })
  window.AppRouter = new AppRouter;
  Backbone.history.start();

  
  
  #Topics.fetch()
  #SS.client.media.init()
  
  
  