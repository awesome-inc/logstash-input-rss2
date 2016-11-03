class Point
    attr_reader :latitude
    attr_reader :longitude

    def initialize(point)
      return nil if point.nil? || point.empty?
      tokens = point.split(' ')
      return nil unless tokens.length == 2
      @latitude = tokens[0]
      @longitude = tokens[1]
    end 

    def is_nil
      return latitude.nil? || longitude.nil?
    end

    def to_s
      return is_nil ? "" : "[#{@latitude} #{@longitude}]"
    end
end
