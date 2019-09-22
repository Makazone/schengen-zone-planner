require 'json'
require 'date'

airports = File.open "./airports.json"
$codes = JSON.load(airports)
airports.close

$schengen_countries = "Austria, Belgium, Czech Republic, Denmark, Estonia, Finland, France, Germany, Greece, Hungary, Iceland, Italy, Latvia, Liechtenstein, Lithuania, Luxembourg, Malta, Netherlands, Norway, Poland, Portugal, Slovakia, Slovenia, Spain, Sweden, Switzerland".split(', ')

MyTrip = Struct.new(:departure_time, :arrival_time, :from, :to) do
    def enters_schengen
        country_to = $codes[to]['country']
        country_from = $codes[from]['country']
        $schengen_countries.include?(country_to) && not($schengen_countries.include?(country_from))
    end

    def leaves_schengen
        country_to = $codes[to]['country']
        country_from = $codes[from]['country']
        $schengen_countries.include?(country_from) && not($schengen_countries.include?(country_to))
    end

    def to_s
        country_from = $codes[from]['country']
        country_to = $codes[to]['country']

        "You traveled from #{country_from} to #{country_to}\n" +
        "Was it to Schengen zone? #{$schengen_countries.include? country_to}\n" +
        "From #{departure_time.strftime("%d %b %Y")} to #{arrival_time.strftime("%d %b %Y")}\n\n"
    end
end

class SchengenVisa
    def initialize(trips)
        @trips = trips
    end

    def schengen_trips
        schengen_trips = @trips.select { |t| t.enters_schengen || t.leaves_schengen }
    end
end

trips = []
previous_line = ""
DATE_FORMAT = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
AIRPORT_CODE_FORMAT = /[A-Z]{3}/
TRIP_FORMAT = /(\d{1});(#{DATE_FORMAT});(#{DATE_FORMAT});(#{AIRPORT_CODE_FORMAT});(#{AIRPORT_CODE_FORMAT})/
file = File.open("./data.txt", "r").each do |line|
    if line.include? "flights"
        previous_line.match(TRIP_FORMAT) do |m| 
            is_it_my = m.captures[0].to_i > 0

            # if is_it_my 
            departure = DateTime.parse m.captures[1]
            arrival = DateTime.parse m.captures[2]
            from = m.captures[3]
            to = m.captures[4]

            is_it_my && trips.push(MyTrip.new(departure, arrival, from, to))
        end
    else
        previous_line = line
    end
end

visa = SchengenVisa.new(trips)
# puts visa.schengen_trips[0].arrival_time
puts visa.schengen_trips.sort { |a, b| a.arrival_time <=> b.arrival_time}
