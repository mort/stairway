module Stairway
  class Venue
  
    attr_reader :traveler
    attr_accessor :id
    
    def initialize(traveler)
      @traveler = traveler
    end
    
    def enter(id)
      @id = id
      @traveler.send(:perform_post, "/journeys/#{@traveler.journey_id}/venues/#{id}/presence")
    end
    
    def leave
      @traveler.send(:perform_delete, "/journeys/#{@traveler.journey_id}/venues/#{@id}/presence")
      @id = nil
    end
  
  end
end