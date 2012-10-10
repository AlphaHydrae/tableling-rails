
var Tableling = Backbone.Marionette.Layout.extend({

  tableling : {
    currentPage : 1,
    pageSize : 15
  },

  initialize : function(options) {

    options = options || {};
    this.tableling = _.extend(_.clone(this.tableling), options.tableling || {});

    this.vent = options.vent || new Backbone.Marionette.EventAggregator();

    this.on('render', this.setup, this);
    this.vent.on('tableling:update', this.update, this);
  },

  update : function(config, options) {
    _.each(_.pick(config, 'currentPage', 'pageSize', 'quickSearch', 'sort'), _.bind(this.updateOne, this));
    if (!options || typeof(options.refresh) == 'undefined' || options.refresh) {
      this.refresh();
    }
  },

  updateOne : function(value, key) {
    if (value) {
      this.tableling[key] = value;
    } else {
      delete this.tableling[key];
    }
  },

  config : function() {
    return _.pick(this.tableling, 'currentPage', 'pageSize', 'quickSearch', 'length', 'total');
  },

  setup : function() {
    this.refresh();
  },

  refresh : function() {
    this.vent.trigger('tableling:refreshing');
    // TODO: add error if collection is missing
    this.collection.fetch({
      type: 'POST',
      data: this.requestData(),
      success: _.bind(this.processResponse, this)
    });
  },

  processResponse : function(collection, response) {
    this.tableling.total = response.total;
    this.tableling.length = collection.length;
    this.vent.trigger('tableling:refreshed', this.config());
  },

  firstRecord : function() {
    return this.collection.length ? (this.tableling.currentPage - 1) * this.tableling.pageSize + 1 : 0;
  },

  lastRecord : function() {
    return this.collection.length ? this.firstRecord() + this.collection.length : 0;
  },

  requestData : function() {

    var data = {
      page: this.tableling.currentPage,
      page_size: this.tableling.pageSize
    };

    if (this.tableling.quickSearch && this.tableling.quickSearch.length) {
      data.quick_search = this.tableling.quickSearch;
    }

    if (this.tableling.sort && this.tableling.sort.length) {
      data.sort = this.tableling.sort
    }

    if (Tableling.debug) {
      console.log(JSON.stringify(data));
    }

    return data;
  },

  tablelingOptions : function(options) {
    if (!options.tableling) {
      options.tableling = {};
    }
    return options.tableling;
  }
});

Tableling.Collection = Backbone.Collection.extend({

  parse : function(response) {
    return response.data;
  }
});
