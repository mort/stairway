module Stairway
  class Tile
  
    attr_reader :id, :traveler
    
    extend Forwardable

    def_delegators :traveler, :perform_get
  
    def initialize(id, traveler)
      @id, @traveler = id, traveler
    end
        
    def method_missing(method_sym, *args)
      self.send(:action, method_sym.to_s, *args)
    end
    
    private
    
    def action(verb, options = {})
      opt = {:method => 'get', :query => {}}
      opt.update(options) unless options.empty?
      
      method = opt.delete(:method)
      @traveler.send("perform_#{method}".to_sym, "/journeys/#{@traveler.journey_id}/tiles/#{self.id}/#{verb}", opt)
    end
  
  end
end