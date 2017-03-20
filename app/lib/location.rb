class Location
  def initialize(zip)
    @zip = zip
  end

  def nearest_starbucks
    @nearest_starbucks ||= nearest_branch 'Starbucks'
  end

  private

  def nearest_branch(name)
    return nil unless geodode.present?
    Rails.cache.fetch("#{self.class.name}/#{@zip}/nearest_branch/#{name}", expires_in: 1.month) do
      query = {
        key: ENV['GOOGLE_PLACES_API_KEY'],
        location: "#{latlng['lat']},#{latlng['lng']}",
        keyword: name,
        rankby: 'distance',
      }
      url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?#{query.to_query}"
      make_google_call(url)
    end['vicinity']
  end

  def locality
    geodode['address_components'][1] if geodode.present?
  end

  def latlng
    geodode['geometry']['location'] if geodode.present?
  end

  def geodode
    @geodode ||= Rails.cache.fetch("#{self.class.name}/#{@zip}/geocode", expires_in: 1.month) do
      query = {key: ENV['GOOGLE_GEOCODING_API_KEY'], components: "postal_code:#{@zip}"}
      url = "https://maps.googleapis.com/maps/api/geocode/json?#{query.to_query}"
      make_google_call url
    end
  end

  def make_google_call(url)
    (HTTParty.get(url).parsed_response['results'].first || {}).with_indifferent_access
  end
end
