require 'json'
require 'date'

airports = File.open "./airports.json"
$codes = JSON.load(airports)
airports.close

$schengen_countries = "Austria, Belgium, Czech Republic, Denmark, Estonia, Finland, France, Germany, Greece, Hungary, Iceland, Italy, Latvia, Liechtenstein, Lithuania, Luxembourg, Malta, Netherlands, Norway, Poland, Portugal, Slovakia, Slovenia, Spain, Sweden, Switzerland".split(', ')

MyFlight = Struct.new(:arrival_time, :from, :to) do
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
        "On #{arrival_time.strftime("%d %b %Y")}\n\n"
    end
end

class MyTrip
    def initialize(fly_in, fly_out)
      @start_date = DateTime.new(fly_in.arrival_time.year, fly_in.arrival_time.month, fly_in.arrival_time.day, 0, 0, 0, 0)
      @end_date = DateTime.new(fly_out.arrival_time.year, fly_out.arrival_time.month, fly_out.arrival_time.day, 0, 0, 0, 0)
    end

    def start_date
        @start_date
    end

    def end_date
        @end_date
    end

    def duration
        (@end_date - @start_date).to_i
    end

    def to_s
        "from " + @start_date.strftime("%d %b %Y") + " until " + @end_date.strftime("%d %b %Y")
    end
end

class SchengenVisa
    def initialize(flights)
        @flights = flights
    end

    def schengen_trips
        sorted_flights = @flights.sort { |a, b| a.arrival_time <=> b.arrival_time }
        fly_in = nil
        trips = []
        sorted_flights.each do |f|
            if !fly_in && f.enters_schengen
                fly_in = f
            elsif fly_in && f.leaves_schengen
                trips.push(MyTrip.new(fly_in, f))
                fly_in = nil
            end
        end
        trips
    end

    def days_left
        today = DateTime.now
        last_day = today - 90
        # last_day
        # trips = @schengen_trips
        days_spent = 0
        self.schengen_trips.reverse.each do |t|
            puts t
            if t.start_date <= last_day && last_day < t.end_date
                days_spent += (t.end_date - last_day).to_i
            elsif t.start_date > last_day
                days_spent += t.duration
            end
        end
        90 - days_spent
    end
end

flights = []
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

            is_it_my && flights.push(MyFlight.new(arrival, from, to))
        end
    else
        previous_line = line
    end
end

visa = SchengenVisa.new(flights)
puts visa.days_left
# visa.schengen_trips.each do |t|
#     puts t
#     puts t.duration
# end
# puts visa.schengen_trips[0].arrival_time
# puts visa.schengen_trips.sort { |a, b| a.arrival_time <=> b.arrival_time}
