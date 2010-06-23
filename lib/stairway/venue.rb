module Stairway
  class Venue
  
    attr_reader :traveler
    
    #undef id
    
    def initialize(traveler)
      @traveler = traveler
      @venue_id = nil
    end
    
    def enter(venue_id)
      @venue_id = venue_id
      @traveler.send(:perform_post, "/journeys/#{@traveler.journey_id}/venues/#{@venue_id}/presence")
    end
    
    def leave
      @traveler.send(:perform_delete, "/journeys/#{@traveler.journey_id}/venues/#{@venue_id}/presence")
      @venue_id = nil
    end
  
  end
end