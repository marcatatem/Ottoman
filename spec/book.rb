class Book < Ottoman::Model

  attribute  :title
  attributes :author, :year, :reference, :flags

  validates_presence_of     :title, :author, :reference
  validates_numericality_of :year

  uuid do |book|
    "#{author}-#{title}".parameterize
  end

  before_validation do |book|
    book.reference = Digest::MD5.hexdigest(book.title)
  end

end