module Traveler
  class Tile
  
    attr_reader :id, :traveler
      
    def initialize(traveler)
      @traveler = traveler
    end
    
    def enter(id)
      @traveler.send(:perform_post, "/journeys/#{@traveler.journey_id}/venues/#{id}/presence")
      @id = id
    end
    
    def leave
       perform_delete("/journeys/#{@traveler.journey_id}/venues/#{@id}/presence")
    end
  
  end
end