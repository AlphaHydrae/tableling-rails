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

var BooksTable = Tableling.Table.extend({
  itemView: BookRow,
  template: false,
  emptyView: NoBookRow
});

$(function() {

  new BooksTable({
    el: $('#books'),
    collection: new BooksCollection({
      model: Book
    })
  }).render();
});
