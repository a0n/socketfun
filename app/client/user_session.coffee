### QUICK CHAT DEMO ####

# Delete this file once you've seen how the demo works

exports.init = ->
  #let jquery load this one
  $(->
    window.LoginView = Backbone.View.extend({

      # Instead of generating a new element, bind to the existing skeleton of
      # the App already present in the HTML.
      el: $("#content"),
      template: $("#login_view")


    # Delegated events for creating new items, and clearing completed ones.
      events: {
        "keypress #login input":  "createOnEnter"
      },
      # At initialization we bind to the relevant events on the `Todos`
      # collection, when items are added or changed. Kick things off by
      # loading any preexisting todos that might be saved in *localStorage*.
      initialize: ->
        _.bindAll(this, 'render')
        this.input    = this.$("#login")
      ,
      createOnEnter: (e) ->
        if e.keyCode != 13
          return
        email = $("#login input[name='email']").val()
        password = $("#login input[name='password']").val()
        params = {email: email, password: password}
        #console.log(params)
        SS.server.app.authenticate(params, (session) ->
          console.log session
          if session.user_id
            window.current_user = session.user_id
            SS.client.topic.init()
            $("body").addClass("booted")
          else
            $("div.error").html(session.error_reason)
        )
      ,
        # Re-rendering the App just means refreshing the statistics -- the rest
      # of the app doesn't change.
      render: ->
        $(this.el).html(this.template.tmpl())
    })

    # Finally, we kick things off by creating the **App**.
    window.App = new LoginView
    window.App.render()
  )
