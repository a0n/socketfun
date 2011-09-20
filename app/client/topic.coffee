### QUICK CHAT DEMO ####

# Delete this file once you've seen how the demo works

exports.load = ->
  $(->
    window.Topic = Backbone.Model.extend({
      # Default attributes for the todo.
      defaults: {

      },

      # Ensure that each todo created has `content`.
      initialize: ->
        self = this
        self.medias = new MediaList(null, {topic_id: self.id})
      , 
      # Remove this Todo from *localStorage* and delete its view.
      clear: ->
        this.destroy()
        $("#topic-" + this.id).remove()
        this.view.remove()
        if this.info_view
          this.info_view.remove()
    })
    
    
    window.TopicList = Backbone.Collection.extend({
      # Reference to this collection's model.
      model: Topic,
      # Save all of the todo items under the `"todos"` namespace.
      localStorage: new Store("topic")
      # Filter down the list of all todo items that are finished.
    })

    # Create our global collection of **Todos**.
    window.Topics = new TopicList
        
   


    # Todo Item View
    # --------------

    # The DOM element for a todo item...
    window.TopicRowView = Backbone.View.extend({

      #... is a list tag.
      tagName:  "li",

      # Cache the template function for a single item.
      template: $( "#topic_row" ),

      # The DOM events specific to an item.
      events: {
        "click":  "open"
      },

      # The TodoView listens for changes to its model, re-rendering. Since there's
      # a one-to-one correspondence between a **Todo** and a **TodoView** in this
      # app, we set a direct reference on the model for convenience.
      initialize: ->
        _.bindAll(this, 'render', 'open')
        this.model.bind('change', this.render)
        this.model.view = this
      ,
      open: ->
        topic_view = new TopicInfoView({model: this.model})
        $("#main").html(topic_view.render().el)
        this.activate()
        AppRouter.navigate("topics/" + this.model.id);
      ,
      activate: ->
        $(".active").removeClass("active")
        $(this.el).addClass("active")
      # Re-render the contents of the todo item.
      render: ->   
        console.log("rerender row")
        position = this.model.get("position")
        if position
          if position.pivot == "BEFORE"
            $("#topic-list #"+position.pivot_topic_id).before($(this.el))
          else if position.pivot == "AFTER"
            console.log("ASFTER")
            $($("#topic-list #"+position.pivot_topic_id)).after(this.el)
        $(this.el).html(this.template.tmpl(this.model.toJSON()))
        $(this.el).attr("id", this.model.id)
        return this
    })
    
    window.TopicInfoView = Backbone.View.extend({
      #... is a list tag.
      tagName:  "div",
      # Cache the template function for a single item.
      template: $( "#topic_info_view" ),

      # The DOM events specific to an item.
      events: {
        "click #delete_topic": "deleteTopic",
        "click .add_notice": "addNotice"
      },

      # The TodoView listens for changes to its model, re-rendering. Since there's
      # a one-to-one correspondence between a **Todo** and a **TodoView** in this
      # app, we set a direct reference on the model for convenience.
      initialize: ->
        _.bindAll(this, 'addOne', 'addAll', 'render')
        this.model.info_view = this
        this.model.medias.bind('add',     this.addOne)
        this.model.medias.bind('reset',   this.addAll)
        this.model.medias.bind('all',     this.render)
        this.model.medias.fetch()
      ,
      addNotice: (e) ->
        alert "add notice"    
      addOne: (media) ->
        view = new MediaRowView({model: media})
        $("#medias").prepend(view.render().el)
      ,
      # Add all items in the **Todos** collection at once.
      addAll: ->
        this.model.medias.each(this.addOne)
      , 
      deleteTopic: ->
        this.model.clear()
        $("#content").prepend("<div id='main'></div>")
      
      # Re-render the contents of the todo item.
      render: ->      
        $(this.el).html(this.template.tmpl(this.model.toJSON()))
        return this
    })
    
  
    window.SidebarView = Backbone.View.extend({

      # Instead of generating a new element, bind to the existing skeleton of
      # the App already present in the HTML.
      el: $("#content"),
      template: $("#sidebar_view"),

    # Delegated events for creating new items, and clearing completed ones.
      events: {
        "keypress .new_topic":  "createOnEnter"
        "click .add_topic"    :  "addNewTopic"
      },
      # At initialization we bind to the relevant events on the `Todos`
      # collection, when items are added or changed. Kick things off by
      # loading any preexisting todos that might be saved in *localStorage*.
      initialize: ->
        _.bindAll(this, 'addOne', 'addAll', 'render')
        this.user_id = this.options.user_id
        this.active_topic_id = this.options.active_topic_id
        self = this
      
        
        Topics.bind('add',     this.addOne)
        Topics.bind('reset',   this.addAll)
        Topics.bind('all',     this.render)
        Topics.fetch({success: (status) ->
          if self.active_topic_id
            topic = Topics.get(self.active_topic_id)
            if topic
              topic_view = new TopicInfoView({model: topic})
              $("#main").html(topic_view.render().el)
            $("#topic-list").sortable({
              revert: true
              update: (e,ui) ->
                console.log $(ui.item).next().attr("id")
                if $(ui.item).attr("id")
                  topic = Topics.get($(ui.item).attr("id"))
                
                  console.log("asdasd")
                  console.log $(ui.item).next()
                
                  if ($(ui.item).next().length > 0)
                    position = {next_topic_id: $(ui.item).next().attr("id")}
                  else if ($(ui.item).prev().length > 0)
                    position = {prev_topic_id: $(ui.item).prev().attr("id")}
                  if position
                    topic.set(position, {silent: true})
                    topic.save()
            })
        		$("#topic-list").disableSelection()
        })
        
      ,

        # Re-rendering the App just means refreshing the statistics -- the rest
      # of the app doesn't change.
      render: ->
      ,
      addNewTopic: ->
        if $(".new_topic").length == 0
          $("#topic-list").prepend($("#new_topic_row").tmpl())
      ,

      createOnEnter: (e) -> 
        if e.keyCode != 13
          return
        self = this
        console.log "danger"
        console.log this.newAttributes()
        x = Topics.create(this.newAttributes(), {
          success: ->
            self.active_topic_id = x.id
            console.log(x.view.open())
        })
        $(e.target).parent().remove()
      ,
      # Generate the attributes for a new Todo item.
      newAttributes: ->
        attr = []
        attr["name"] = $("#new-topic").val()
        if $(".new_topic").next().length > 0
          attr["next_topic_id"] = $(".new_topic").next().attr("id")
        else if $(".new_topic").prev().length > 0
          attr["prev_topic_id"] = $(".new_topic").prev().attr("id")
        return attr
      ,
      # Add a single todo item to the list by creating a view for it, and
      # appending its element to the `<ul>`.
      addOne: (topic) ->
        view = new TopicRowView({model: topic})
        if topic.id == this.active_topic_id
          view.activate()
        
        position = topic.get("position")
        if position
          if position.pivot == "BEFORE"
            $("#" + position.pivot_topic_id).before(view.render().el)
          else if position.pivot == "AFTER"
            $("#" + position.pivot_topic_id).after(view.render().el)
            console.log("AFTER")
        else
          this.$("#topic-list").append(view.render().el)
      ,
      # Add all items in the **Todos** collection at once.
      addAll: ->
        Topics.each(this.addOne)
    })
  )

exports.init = (options) ->
  #let jquery load this one
  
  options || (options = {})
  
  SS.events.on 'newTopic', (topic) ->
    existing_topic = Topics.get(topic.id)
    if existing_topic
    else
      Topics.add(topic)
      
  SS.events.on 'updateTopic', (params) ->
    console.log("UPPPPPDATE")
    
    console.log(params)
    existing_topic = Topics.get(params.id)
    delete params["id"]
    console.log(existing_topic.set(params))
    console.log(existing_topic)
        
  SS.events.on 'deleteTopic', (topic_id) ->
    existing_topic = Topics.get(topic_id)
    if existing_topic
      existing_topic.clear()
  $(->
    # Finally, we kick things off by creating the **App**.
    $("#content").html($("#main_view").tmpl())
    $("#sidebar").html($("#sidebar_view").tmpl())
    window.Sidebar = new SidebarView(options)
  )