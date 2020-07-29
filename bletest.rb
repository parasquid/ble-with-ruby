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

puts adapter.devices

byebug

device = adapter["EB:CC:BB:49:2A:DE"]

device.connect

sleep(1)

puts device.characteristics("0000181c-0000-1000-8000-00805f9b34fb")

byebug

# add the String characteristic to the library
BLE::Characteristic.add 0x2A3D,
  name: 'String',
  type: 'org.bluetooth.characteristic.string',
  in: ->(s) { s.force_encoding('UTF-8') },
  out: ->(v) { v.encode('UTF-8') }

# writing values to characteristics (needs write attribute)

r = 0x60; g = 0x00; b = 0x00; x = 0x01; y = 0x02
device.write(:user_data, :string, [r, g, b, x, y].pack('C*'), raw: true)

byebug

def colorwipe(device, r, g, b)
  0.upto(7) do |x|
    0.upto(7) do |y|
      device.write(:user_data, :string, [r, g, b, x, y].pack('C*'), raw: true)
    end
  end
end

r = 0; g = 0; b = 0;
colorwipe(device, x, g, b)

r = 0; g = 0; b = 0;
colorwipe(device, r, x, b)

r = 0; g = 0; b = 0;
colorwipe(device, r, g, x)

r = 0; g = 0; b = 0;
colorwipe(device, x, x, b)

r = 0; g = 0; b = 0;
colorwipe(device, r, x, x)

r = 0; g = 0; b = 0;
colorwipe(device, x, g, x)

r = 0; g = 0; b = 0;
colorwipe(device, x, x, x)

byebug

device.disconnect

byebug

# reading values from characteristics (needs read attribute)

device = adapter["E3:B6:8D:7E:01:9C"]
device.connect
puts device.name

puts device[:user_data, :string]

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
