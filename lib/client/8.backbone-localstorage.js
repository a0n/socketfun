

// Our Store is represented by a single JS object in *localStorage*. Create it
// with a meaningful name, like the name you'd give a table.
var Store = function(name) {
  this.name = name;
  var store = localStorage.getItem(this.name);
  this.records = (store && store.split(",")) || [];
};

_.extend(Store.prototype, {
  // Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
  // have an id of it's own.
  
  save: function() {
    localStorage.setItem(this.name, this.records.join(","));
  },
  create: function(model, callbacks, options) {
    store = this
    //console.log(model);
    SS.server[this.name]["create"](model.attributes, function(response){
      if (status == false) {
        callbacks.error(response);
      } else {
        if (response.id) {
          localStorage.setItem(store.name+"-"+response.id, JSON.stringify(response));
          store.records.push(response.id.toString());
          store.save()
          callbacks.success(response);
        } else {
          callbacks.error(response);
        }
      }
    });
  },

  // Update a model by replacing its copy in `this.data`.
  update: function(model, callbacks, options) {
    store = this
    console.log("update");
    var attributes = model.changedAttributes();
    
    //if changed attributes are empty lets just send all attributes to make sure nothing went wrong
    if (attributes.length == 0) {
      console.log("WARNING! not using changed attributes for this update");
      attributes = model.attributes;
    }
    
    attributes["id"] = model.id;
    console.log(attributes);
    SS.server[this.name]["update"](attributes, function(response){
       if (response == false) {
          callbacks.error(response);
        } else {
          localStorage.setItem(store.name+"-"+response.id, JSON.stringify(response));
          if (!_.include(store.records, response.id.toString())) store.records.push(response.id.toString()); store.save();
          callbacks.success(response);
        }
    });
  },

  // Retrieve a model from `this.data` by id.
  find: function(model, callbacks, options) {
    var model = localStorage.getItem(this.name+"-"+model.id)
    if (model) {
      console.log("FIND VIA LOCALSTORE");
      callbacks.success(model);
    } else {
      SS.server[this.name]["find"](model.id, function(record){
        console.log("FIND VIA SERVER");
        callbacks.success(record);
      });  
    }
  },

  // Return the array of all models currently in storage.
  findAll: function(callbacks, options) {
    var store = this;
    SS.server[this.name]["all"](options, function(all){
      console.log("FIND ALL VIA SERVER");
      console.log(all.length);
      console.log(all);
      old_records = localStorage.getItem(store.name);
      if (old_records) {
        _.each(old_records.split(","), function(id){
          localStorage.removeItem(store.name+"-"+id);
        });
      }
      store.records = []
      _.each(all, function(record) { 
        if(!_.isEmpty(record)) {
          localStorage.setItem(store.name+"-"+record.id, JSON.stringify(record));
          store.records.push(record.id.toString());
        }
      });
      store.save()
      callbacks.success(all)
    });
  },

  // Delete a model from `this.data`, returning it.
  destroy: function(model, callbacks, options) {
    store = this
    SS.server[this.name]["delete"](model.id, function(status){
      localStorage.removeItem(store.name+"-"+model.id);
      store.records = _.reject(store.records, function(record_id){return record_id == model.id.toString();});
      store.save();      
      callbacks.success(status);
    });
  }

});

// Override `Backbone.sync` to use delegate to the model or collection's
// *localStorage* property, which should be an instance of `Store`.
Backbone.sync = function(method, model, options) {
  
  var resp;
  var store = model.localStorage || model.collection.localStorage;
  var callbacks = {error: options.error, success: options.success}
  delete options.error
  delete options.success
  if (model.options) {
    options = model.options;
  }
  
  console.log("SYNC");
  console.log(store.name + " " + method);
  console.log(model);
  console.log(options);
  console.log(callbacks);
  
  //console.log(options);
  switch (method) {
    case "read":    resp = model.id ? store.find(model, callbacks, options) : store.findAll(callbacks, options); break;
    case "create":  resp = store.create(model, callbacks, options);                            break;
    case "update":  resp = store.update(model, callbacks, options);                            break;
    case "delete":  resp = store.destroy(model, callbacks, options);                           break;
  }
};