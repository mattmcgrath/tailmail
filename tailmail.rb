require 'socket'
require 'csv'
require 'rushover'
require 'json'

settings = JSON.parse(File.read('/home/pi/tailmail/config.json'))

port = 30003 # dump1090 offers CSV data on this port

socket = TCPSocket.new('localhost', port)
client = Rushover::Client.new(settings['appkey'])
user_key = settings['apikey']



aircraft = {}
watchlist = {}

puts "Opening watchlist file #{ARGV[0]}..."
CSV.foreach(ARGV[0]) do |row|
  watchlist[row[0]] = {tailnumber: row[1], model: row[2], owner: row[3]}
end

puts "Listening on port #{port}..."
while line = socket.gets
  icao = line.split(',')[4]
  if watchlist.key?(icao)
    d = watchlist[icao]
    time = Time.now
    if aircraft[icao].nil?
      aircraft[icao] = time
      puts "Saw #{d[:tailnumber]} - #{d[:model]} (#{d[:owner]}) at #{time}."
      client.notify(user_key, "Saw #{d[:tailnumber]} - #{d[:model]} (#{d[:owner]}) at #{time}.", priority: 1, title: 'Aircraft Notification')
    end
  end
end

socket.close
