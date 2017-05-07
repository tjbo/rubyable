class Target
  def initialize(uri, fetched)
    #fetched means we have gotten the link
    @uri = uri
    @fetched = fetched
    @processing = false
  end

  def start_processing
    self.processing = true
  end

end
