class BooksController < ApplicationController

  def page
    render :json => Book.tableling.process(params)
  end
end
