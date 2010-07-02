module Stairway
  class Traveler
    extend Forwardable

    def_delegators :client, :get, :post, :put, :delete

    attr_reader :client, :journey_id, :user_id, :tile_id, :venue_id, :tile, :venue

    def initialize(client)
      @client = client
    end
        
    def ping(lat, lon, query={})
      response = perform_post("/pings", :body => {:lat => lat, :lon => lon}.merge(query))
      @journey_id =  response['meta']['journey_id']
      @user_id =  response['meta']['user_id']
      @tile_id =  response['meta']['tile_id']
      response
    end
    
    def tile
      Stairway::Tile.new(@tile_id, self)
    end
    
    def venue(venue_id)
      Stairway::Venue.new(venue_id, self)
    end
    
    protected

    def self.mime_type(file)
      case
        when file =~ /\.jpg/ then 'image/jpg'
        when file =~ /\.gif$/ then 'image/gif'
        when file =~ /\.png$/ then 'image/png'
        else 'application/octet-stream'
      end
    end

    def mime_type(f) self.class.mime_type(f) end

    CRLF = "\r\n"

    def self.build_multipart_bodies(parts)
      boundary = Time.now.to_i.to_s(16)
      body = ""
      parts.each do |key, value|
        esc_key = CGI.escape(key.to_s)
        body << "--#{boundary}#{CRLF}"
        if value.respond_to?(:read)
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
          body << "Content-Type: #{mime_type(value.path)}#{CRLF*2}"
          body << value.read
        else
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
        end
        body << CRLF
      end
      body << "--#{boundary}--#{CRLF*2}"
      {
        :body => body,
        :headers => {"Content-Type" => "multipart/form-data; boundary=#{boundary}"}
      }
    end

    def build_multipart_bodies(parts) self.class.build_multipart_bodies(parts) end

    private

    def perform_get(path, options={})
      Stairway::Request.get(self, path, options)
    end

    def perform_post(path, options={})
      Stairway::Request.post(self, path, options)
    end

    def perform_put(path, options={})
      Stairway::Request.put(self, path, options)
    end

    def perform_delete(path, options={})
      Stairway::Request.delete(self, path, options)
    end

  end
end
