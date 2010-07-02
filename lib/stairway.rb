require "forwardable"
require "oauth"
require "hashie"
require "httparty"
require "yajl"

module Stairway
  include HTTParty
  API_VERSION = "1".freeze
  base_uri "durden.dev"
  format :json

  class StairwayError < StandardError
    attr_reader :data

    def initialize(data)
      @data = data
      super
    end
  end

  class NotInVenue < StairwayError; end
  class Unauthorized < StairwayError; end
  class General < StairwayError; end

  class Unavailable   < StandardError; end
  class NotFound      < StandardError; end


  private

  def self.make_friendly(response)
    raise_errors(response)
    data = parse(response)
    # Don't mash arrays of integers
    if data && data.is_a?(Array) && data.first.is_a?(Integer)
      data
    else
      mash(data)
    end
  end

  def self.raise_errors(response)
    case response.code.to_i
      when 400
        data = parse(response)
        raise RateLimitExceeded.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 401
        data = parse(response)
        raise Unauthorized.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 403
        data = parse(response)
        raise General.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 404
        raise NotFound, "(#{response.code}): #{response.message}"
      when 500
        raise StairwayError, "Traveler had an internal error. Please let them know in the group. (#{response.code}): #{response.message}"
      when 502..503
        raise Unavailable, "(#{response.code}): #{response.message}"
    end
  end

  def self.parse(response)
    Yajl::Parser.parse(response.body) unless response.body.nil?
  end

  def self.mash(obj)
    if obj.is_a?(Array)
      obj.map{|item| make_mash_with_consistent_hash(item)}
    elsif obj.is_a?(Hash)
      make_mash_with_consistent_hash(obj)
    else
      obj
    end
  end

  # Lame workaround for the fact that mash doesn't hash correctly
  def self.make_mash_with_consistent_hash(obj)
    m = Hashie::Mash.new(obj)
    def m.hash
      inspect.hash
    end
    return m
  end

end

module Hashie
  class Mash

    # Converts all of the keys to strings, optionally formatting key name
    def rubyify_keys!
      keys.each{|k|
        v = delete(k)
        new_key = k.to_s.underscore
        self[new_key] = v
        v.rubyify_keys! if v.is_a?(Hash)
        v.each{|p| p.rubyify_keys! if p.is_a?(Hash)} if v.is_a?(Array)
      }
      self
    end

  end
end

directory = File.expand_path(File.dirname(__FILE__))

require File.join(directory, "stairway", "oauth")
require File.join(directory, "stairway", "request")
require File.join(directory, "stairway", "traveler")
require File.join(directory, "stairway", "tile")
require File.join(directory, "stairway", "venue")