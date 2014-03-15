require "digest"
require "spec_helper"
require "./lib/ottoman"
require "book"

describe Ottoman do

  before :all do
    # Connect to Couchbase server
    @client = Ottoman.client || Ottoman.connect(bucket: 'default')
  end

  describe '#client' do

    it "should be an instance of Bucket" do
      @client.client.should be_instance_of(Couchbase::Bucket)
    end

  end

  describe Book do

    describe '#new' do

      it "should return a new instance of Book" do
        book = Book.new( title: "Hello World!", author: "Marca Tatem", year: 2013 ).should be_an_instance_of Book
      end

      it "should be marked as new record" do
        -> { book.new_record? }.should be_true
      end

    end

    describe '#create' do

      before :all do
        @book = Book.create( title: "Hello World!", author: "Marca Tatem", year: 2013 )
      end

      after :all do
        @book.delete unless @book.frozen?
      end

      it "should create an instance of Book" do
        @book.should be_an_instance_of Book
      end

      it "should have persisted?" do
        -> { @book.persisted? }.should be_true
      end

      it "should have an id (uuid)" do
        @book.id.should be_an_instance_of String
      end

      it "should be accessible on the datastore" do
        book = Book.fetch(@book.id)
        book.id.should eql @book.id
        book.title.should eql @book.title
      end

      it "should fail when one tries to create an object with the same id (uuid)" do
        -> { Book.create( title: "Hello World!", author: "Marca Tatem", year: 2013 ) }.should raise_error
      end

      it "should delete the object from the datastore" do
        -> { @book.delete }.should_not raise_error
      end

      it "should be frozen" do
        -> { @book.frozen? }.should be_true
      end

      it "should be removed from the datastore" do
        Book.fetch(@book.id).should be_nil
      end

    end

    describe '#validation' do

      before :all do
        @book = Book.new( title: "Hello World!", author: "Marca Tatem", year: "Should be a number really" )
      end

      it "should return false when validations don't pass" do
        @book.save.should be_false
      end

      it "should respond to #errors" do
        -> { @book.respond_to?(:errors) }.should be_true
      end

      it "should have one (1) error preventing it to be saved" do
        @book.errors.count.should eql 1
      end

    end

    describe '#update' do

      before :all do
        @book = Book.create( title: "Hello World!", author: "Marca Tatem", year: 2013 )
      end

      after :all do
        @book.delete(true) # -> force = true, this is required because the cas (check-and-set parameter) has changed
      end

      it "should update the year attribute" do
        -> { @book.update_attribute(:year, 2015) }.should_not raise_error
      end

      it "should have saved the modifications on the datastore" do
        Book.fetch(@book.id).year.should eq 2015
      end

      it "should update many attributes at once" do
        -> { @book.update_attributes(year: 2030, author: "Melvil Dewey") }.should_not raise_error
      end

      it "should have saved the modifications on the datastore (multiple)" do
        Book.fetch(@book.id).year.should eq 2030
        Book.fetch(@book.id).author.should eq "Melvil Dewey"
      end

      it "should fail to update the record if a validation callback returns false" do
        @book.update_attribute(:year, "It should be a string really").should be_false
        @book.update_attributes(author: "Melvil Dewey", year: "It should be a string really").should be_false
      end

      it "should fail to save the record if the check-and-set parameter has changed since you last fetched the record" do
        another_instance_of_book = Book.fetch(@book.id)
        another_instance_of_book.update_attribute(:year, 2015)
        -> { @book.update_attribute(:year, 2030) }.should raise_error
      end

    end

    describe '#schema' do

      before :all do
        @book = Book.create( title: "Hello World!", author: "Marca Tatem", year: 2013 )
      end

      after :all do
        @book.delete
        Ottoman.client.delete('books:parliament-do-that-stuff') rescue nil # -> cleaning up
      end

      it "should be possible to store arbitrary types of data in attributes" do
        -> { @book.update_attribute(:flags, language: :en, isbn_10: '0201633612') }.should_not raise_error
        @book.flags[:language].should eql :en
      end

      it "should not be possible to overide validation statements though" do
        @book.update_attribute(:year, language: :en, isbn_10: '0201633612').should be_false
      end

      it "should be possible to save the record nevertheless once the eror has been fixed" do
        @book.year = 2013
        @book.save.should be_an_instance_of Book
      end

      it "should not be possible to set an attribute that hasn't been declared in the model" do
        -> { @book.publisher = "Addison-Wesley" }.should raise_error
        -> { @book.update_attribute(:publisher, "Addison-Wesley") }.should raise_error
        -> { @book.update_attributes(publisher: "Addison-Wesley") }.should raise_error
      end

      it "should be possible to bypass the model constraints by accessing the datastore directly" do
        -> { Ottoman.client.add('books:parliament-do-that-stuff', title: "Do that stuff", author: "Parliament", publisher: "Casablanca") }.should_not raise_error
      end

      it "should ignore silently undeclared attributes from the raw json input when loaded with the model's fetch method" do
        queer = Book.fetch('parliament-do-that-stuff')
        queer.should be_an_instance_of Book
      end

      it "should not allow the manipulation of the discarded attributes though" do
        queer = Book.fetch('parliament-do-that-stuff')
        -> { publisher = queer.publisher }.should raise_error
      end

      it "should be able to delete the record anyway" do
        queer = Book.fetch('parliament-do-that-stuff')
        -> { queer.delete }.should_not raise_error
      end

    end

  end

end