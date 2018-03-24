class Point
    attr_reader :latitude
    attr_reader :longitude

    def initialize(point)
      return if point.nil? || point.empty?
      tokens = point.split(' ')
      return unless tokens.length == 2
      @latitude = tokens[0]
      @longitude = tokens[1]
    end
end
