
var Tableling = {};

Tableling.Collection = Backbone.Collection.extend({

  parse : function(response) {
    return response.data;
  }
});

Tableling.Table = Backbone.Marionette.CompositeView.extend({

  itemViewContainer: 'tbody',

  ui : {
    pageSize : '.tableling_page_size',
    quickSearch : '.tableling_quick_search',
    firstPage : '.tableling_page .first',
    previousPage : '.tableling_page .previous',
    nextPage : '.tableling_page .next',
    lastPage : '.tableling_page .last',
    infoFirst : '.tableling_info .first',
    infoLast : '.tableling_info .last',
    infoTotal : '.tableling_info .total'
  },

  events : {
    'click .sorting': 'changeSort',
    'click .sorting-asc': 'changeSort',
    'click .sorting-desc': 'changeSort'
  },

  triggers : {
    'change .tableling_page_size' : 'changePageSize',
    'change .tableling_quick_search' : 'changeQuickSearch',
    'click .tableling_page .first:not(.disabled)' : 'goToFirstPage',
    'click .tableling_page .previous:not(.disabled)' : 'goToPreviousPage',
    'click .tableling_page .next:not(.disabled)' : 'goToNextPage',
    'click .tableling_page .last:not(.disabled)' : 'goToLastPage',
  },

  initialize : function() {
    this.collection.on('reset', this.clearLoading, this);
    this.bind('composite:rendered', this.setup, this);
    this.on('refreshTable', _.bind(this.refresh, this));
    this.on('goToFirstPage', _.bind(this.goToFirstPage, this));
    this.on('goToPreviousPage', _.bind(this.goToPreviousPage, this));
    this.on('goToNextPage', _.bind(this.goToNextPage, this));
    this.on('goToLastPage', _.bind(this.goToLastPage, this));
    this.on('changeSort', _.bind(this.changeSort, this));
    this.on('changePageSize', _.bind(this.changePageSize, this));
    this.on('changeQuickSearch', _.bind(this.changeQuickSearch, this));
    this.tableling = {};
    this.tableling.currentPage = 1;
    this.tableling.sort = [];
  },

  changePageSize : function() {
    this.tableling.currentPage = 1;
    this.refresh();
  },

  changeQuickSearch : function() {
    this.tableling.currentPage = 1;
    this.refresh();
  },

  changeSort : function(ev) {

    var el = $(ev.currentTarget);
    var field = this.fieldName(el);

    this.tableling.currentPage = 1;

    if (ev.shiftKey || this.tableling.sort.length == 1) {

      var existing = _.find(this.tableling.sort, function(item) {
        return item.field == field;
      });

      if (existing) {
        existing.direction = existing.direction == 'asc' ? 'desc' : 'asc';
        el.removeClass('sorting sorting-asc sorting-desc');
        el.addClass('sorting-' + existing.direction);
        return this.refresh();
      };
    }

    if (!ev.shiftKey) {
      this.tableling.sort = [];
      this.$el.find('thead th').removeClass('sorting sorting-asc sorting-desc').addClass('sorting');
    }

    this.tableling.sort.push({
      field: field,
      direction: 'asc'
    });

    el.removeClass('sorting sorting-asc sorting-desc').addClass('sorting-asc');

    this.refresh();
  },

  fieldName : function(element) {
    return element.data('field') || element.text().toLowerCase();
  },

  goToFirstPage : function() {
    this.tableling.currentPage = 1;
    this.updatePageControls();
    this.refresh();
  },

  goToPreviousPage : function() {
    this.tableling.currentPage--;
    this.updatePageControls();
    this.refresh();
  },

  goToNextPage : function() {
    this.tableling.currentPage++;
    this.updatePageControls();
    this.refresh();
  },

  goToLastPage : function() {
    this.tableling.currentPage = Math.ceil(this.tableling.total / this.pageSize());
    this.updatePageControls();
    this.refresh();
  },

  updatePageControls : function() {
    this.ui.firstPage.addClass('disabled');
    this.ui.previousPage.addClass('disabled');
    this.ui.nextPage.addClass('disabled');
    this.ui.lastPage.addClass('disabled');
    if (this.tableling.currentPage > 1) {
      this.ui.firstPage.removeClass('disabled');
      this.ui.previousPage.removeClass('disabled');
    }
    if (this.tableling.currentPage * this.pageSize() < this.tableling.total) {
      this.ui.nextPage.removeClass('disabled');
      this.ui.lastPage.removeClass('disabled');
    }
  },

  setup : function() {
    this.updatePageControls();
    this.refresh();
  },

  refresh : function() {
    this.collection.fetch({
      type: 'POST',
      data: this.requestData(),
      success: _.bind(this.processResponse, this)
    });
  },

  processResponse : function(collection, response) {
    this.tableling.total = response.total;
    var first = (this.tableling.currentPage - 1) * this.pageSize() + 1;
    var last = first + this.collection.length - 1;
    if (!this.collection.length) {
      first = 0;
      last = 0;
    };
    this.ui.infoFirst.text(first);
    this.ui.infoLast.text(last);
    this.ui.infoTotal.text(this.tableling.total);
    this.updatePageControls();
  },

  pageSize : function() {
    var pageSize = this.ui.pageSize.val();
    return pageSize.length ? pageSize : 10;
  },

  requestData : function() {

    var data = {
      page: this.tableling.currentPage,
      page_size: this.pageSize()
    };

    if (this.tableling.sort.length) {
      data.sort = this.sortData();
    }

    if (this.ui.quickSearch.val().length) {
      data.quick_search = this.ui.quickSearch.val();
    }

    if (Tableling.debug) {
      console.log(JSON.stringify(data));
    }

    return data;
  },

  sortData : function() {
    return _.map(this.tableling.sort, function(item) {
      return item.field + ' ' + item.direction;
    });
  },

  clearLoading : function() {
    this.$el.find('tr.loading').remove();
  }
});
