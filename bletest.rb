#!/home/tristan/.rvm/rubies/ruby-2.6.2/bin/ruby

require 'ble'
require 'byebug'

adapter = BLE::Adapter.new('hci0')
puts "Info: #{adapter.iface} #{adapter.address} #{adapter.name}"

adapter.start_discovery
puts "discovering ..."
sleep 2
puts "... done"
adapter.stop_discovery

byebug

device = adapter["E3:B6:8D:7E:01:9C"]
puts device.name

device.connect

puts device.characteristics("0000181c-0000-1000-8000-00805f9b34fb")

byebug

BLE::Characteristic.add 0x2A3D,
  name: 'String',
  type: 'org.bluetooth.characteristic.string',
  in: ->(s) { s.force_encoding('UTF-8') },
  out: ->(v) { v.encode('UTF-8') }

puts device[:user_data, :string]

byebug

# device.subscribe(:user_data, :string) {|val| puts val}

# subscription doesn't seem to be supported by this library yet, so we just
# loop read the characteristic

trap "SIGINT" do
  puts "Exiting"
  exit 130
end

while(true)
  puts device[:user_data, :string]
end

sleep(1)
puts
