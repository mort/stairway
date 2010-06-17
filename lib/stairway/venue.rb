module Stairway
  class Venue
    attr_reader :id, :traveler
    
    def initialize(traveler)
      @traveler = traveler
      @id = nil
    end
    
    def enter(id)
      @traveler.send(:perform_post, "/journeys/#{@traveler.journey_id}/venues/#{id}/presence")
      @id = id
      puts "@id = #{@id}"
    end
    
    def leave
      raise Stairway::NotInVenue if @id.nil?
      id = @id
      @traveler.send(:perform_delete, "/journeys/#{@traveler.journey_id}/venues/#{id}/presence")
      puts "Leaving #{@id}"
      @id = nil
    end
  
  end
end