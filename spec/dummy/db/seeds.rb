# encoding: UTF-8

[
  {
    :title => "Nineteen Eighty-Four",
    :author => "George Orwell",
    :year => 1949
  },
  {
    :title => "Fahrenheit 451",
    :author => "Ray Bradbury",
    :year => 1953
  },
  {
    :title => "A Tale of Two Cities",
    :author => "Charles Dickens",
    :year => 1859
  },
  {
    :title => "Robinson Crusoe",
    :author => "Daniel Defoe",
    :year => 1719
  },
  {
    :title => "Emma",
    :author => "Jane Austen",
    :year => 1815
  },
  {
    :title => "Frankenstein",
    :author => "Mary Shelley",
    :year => 1818
  },
  {
    :title => "The Count of Monte Cristo",
    :author => "Alexandre Dumas",
    :year => 1844
  },
  {
    :title => "Wuthering Heights",
    :author => "Emily Brontë",
    :year => 1847
  },
  {
    :title => "The Woman in White",
    :author => "Wilkie Collins",
    :year => 1859
  },
  {
    :title => "Alice's Adventures In Wonderland",
    :author => "Lewis Carroll",
    :year => 1865
  },
  {
    :title => "The Portrait of a Lady",
    :author => "Henry James",
    :year => 1881
  },
  {
    :title => "Brave New World",
    :author => "Aldous Huxley",
    :year => 1932
  }
].each_with_index do |data,i|
  b = Book.new
  b.title = data[:title]
  b.author = data[:author]
  b.year = data[:year]
  b.created_at = (Time.now - (i + 5).days)
  b.updated_at = b.created_at + rand(3).days
  puts %|Added "#{data[:title]}"|
  b.save!
end
