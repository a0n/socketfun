### QUICK CHAT DEMO ####

# Delete this file once you've seen how the demo works

exports.load =  ->
  #let jquery load this one
  $(->
    window.Media = Backbone.Model.extend({
      # Default attributes for the todo.
      defaults: {

      },

      # Ensure that each todo created has `content`.
      initialize: ->
        self = this
      ,
      # Remove this Todo from *localStorage* and delete its view.
      clear: ->
        this.destroy()
        this.view.remove()
    })
  
    window.MediaList = Backbone.Collection.extend({
      # Reference to this collection's model.
      model: Media,
      # Save all of the todo items under the `"todos"` namespace.
      localStorage: new Store("media")
      initialize: (models, options) ->
        this.options = options
      # Filter down the list of all todo items that are finished.
    })

    # Todo Item View
    # --------------

    # The DOM element for a todo item...
    window.MediaRowView = Backbone.View.extend({
      #... is a list tag.
      tagName:  "li",

      # Cache the template function for a single item.
      template: $( "#media_row" ),

      # The DOM events specific to an item.
      events: {

      },

      # The TodoView listens for changes to its model, re-rendering. Since there's
      # a one-to-one correspondence between a **Todo** and a **TodoView** in this
      # app, we set a direct reference on the model for convenience.
      initialize: ->
        _.bindAll(this, 'render')
        this.model.bind('change', this.render)
        this.model.view = this
      ,
      # Re-render the contents of the todo item.
      render: ->      
        $(this.el).html(this.template.tmpl(this.model.toJSON()))
        return this
    })
  )