require 'uri'
require 'json'
require 'active_support'

class Params
  attr_reader :req

  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    @req = req
    @permitted_keys = []

    parse_www_encoded_form(req.query_string) unless req.query_string.nil?
    parse_www_encoded_form(req.body) unless req.body.nil?
    @params.merge!(route_params)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys.concat(keys)
  end

  def require(key)
    raise AttributeNotFoundError unless @params.keys.include?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    value_pairs = URI.decode_www_form(www_encoded_form) 

    value_pairs.each do |value_pair|
      parsed_key = parse_key(value_pair.first)
      value = value_pair.last

      if parsed_key.length > 1
        @params.deep_merge!(params_to_hash(parsed_key, value))
      else
        @params[parsed_key.first] = value
      end
    end
  end

  def parse_post_data(post_data)
    post_data.try(:split, "=")
  end

  def params_to_hash(parsed_key, value)
    parsed_key.length <= 1 ?
      { (parsed_key.first) => value } :
      { (parsed_key.first) => params_to_hash(parsed_key[1..-1], value) }
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
