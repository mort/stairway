module Stairway
  class Venue
  
    
    attr_reader :traveler, :venue_id
        
    def initialize(venue_id, traveler)
      @traveler = traveler
      @venue_id = venue_id
    end
    
    def enter
      @traveler.send(:perform_post, "/journeys/#{@traveler.journey_id}/venues/#{@venue_id}/presence")
    end
    
    def leave
      @traveler.send(:perform_delete, "/journeys/#{@traveler.journey_id}/venues/#{@venue_id}/presence")
    end
  
  end
end