module Stairway
  class Tile
  
    attr_reader :id, :traveler
    
    extend Forwardable

    def_delegators :traveler, :perform_get
  
    def initialize(id, traveler)
      @id, @traveler = id, traveler
    end
    
    def look
      @traveler.send(:perform_get, "/journeys/#{@traveler.journey_id}/tiles/#{self.id}/look")
    end
  
  end
end