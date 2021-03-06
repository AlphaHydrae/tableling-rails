// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var Book = Backbone.Model.extend({
});

var BooksCollection = Tableling.Collection.extend({
  url: '/books/page'
});

var NoBookRow = Backbone.Marionette.ItemView.extend({
  tagName: 'tr',
  className: 'empty',
  template: 'booksTableEmptyRow'
});

var BookRow = Backbone.Marionette.ItemView.extend({

  tagName: 'tr',
  template: 'booksTableRow',

  ui : {
    title: '.title',
    author: '.author'
  },

  onRender : function() {
    this.ui.title.text(this.model.get('title'));
    this.ui.author.text(this.model.get('author'));
  }
});

var BooksTableView = Tableling.Bootstrap.TableView.extend({

  itemView: BookRow,
  emptyView: NoBookRow,
  itemViewContainer: 'tbody',

  initialize : function(options) {
    Tableling.Bootstrap.TableView.prototype.initialize.call(this, options);
    this.on('composite:rendered', this.clearLoading, this);
  },

  clearLoading : function() {
    this.$el.find('tr.loading').remove();
  }
});

var BooksTable = Tableling.Bootstrap.Table.extend({

  tableView : BooksTableView,
  tableViewOptions : {
    template: 'booksTableView',
    collection: new BooksCollection({
      model: Book
    })
  },
  pageSizeViewOptions : {
    sizes : [ 5, 10, 15 ]
  }
});

$(function() {

  var table = new BooksTable({
    pageSize: 5,
    fetchOptions: {
      type: 'POST'
    }
  });

  new Backbone.Marionette.Region({
    el: '#books'
  }).show(table);
});
