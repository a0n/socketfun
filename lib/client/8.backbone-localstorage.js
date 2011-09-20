

// Our Store is represented by a single JS object in *localStorage*. Create it
// with a meaningful name, like the name you'd give a table.
var Store = function(name) {
  this.name = name;
};

_.extend(Store.prototype, {
  // Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
  // have an id of it's own.
  create: function(model, callbacks, options) {
    //console.log(model);
    SS.server[this.name]["create"](model.attributes, function(status){
      if (status == false) {
        callbacks.error(status);
      } else {
        callbacks.success(status);
      }
    });
  },

  // Update a model by replacing its copy in `this.data`.
  update: function(model, callbacks, options) {
    console.log("update");
    var attributes = model.changedAttributes();
    attributes["id"] = model.id;
    console.log(attributes);
    SS.server[this.name]["update"](attributes, function(status){
       if (status == false) {
          callbacks.error(status);
        } else {
          callbacks.success(status);
        }
    });
  },

  // Retrieve a model from `this.data` by id.
  find: function(model, callbacks, options) {
    SS.server[this.name]["find"](model.id, function(record){
      callbacks.success(record)
    });
  },

  // Return the array of all models currently in storage.
  findAll: function(callbacks, options) {
    return SS.server[this.name]["all"](options, function(all){
      console.log(all);
      callbacks.success(all);
    });
  },

  // Delete a model from `this.data`, returning it.
  destroy: function(model, callbacks, options) {
    
    SS.server[this.name]["delete"](model.id, function(status){
      callbacks.success(status)
    });
  }

});

// Override `Backbone.sync` to use delegate to the model or collection's
// *localStorage* property, which should be an instance of `Store`.
Backbone.sync = function(method, model, options) {
  console.log("SYNC")
  console.log(method)
  console.log(model)
  console.log(options)
  
  
  var resp;
  var store = model.localStorage || model.collection.localStorage;
  var callbacks = {error: options.error, success: options.success}
  delete options.error
  delete options.success
  if (model.options) {
    options = model.options;
  }
  //console.log(options);
  switch (method) {
    case "read":    resp = model.id ? store.find(model, callbacks, options) : store.findAll(callbacks, options); break;
    case "create":  resp = store.create(model, callbacks, options);                            break;
    case "update":  resp = store.update(model, callbacks, options);                            break;
    case "delete":  resp = store.destroy(model, callbacks, options);                           break;
  }
};