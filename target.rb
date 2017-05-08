require 'uri'

class Target
  attr_reader :uri

  def initialize(uri, fetched, filename, parentUri)
    #fetched means we have downloaded and copied the file
    @uri = uri
    @fetched = fetched
    @filename = filename
    @parentUri = parentUri
  end

  def is_local
    @uri.include? URI(@parentUri).host
  end

end
