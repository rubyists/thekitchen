#
# Cookbook Name:: audit
# Recipe:: default
#
# Copyright (c) 2015 The Rubyists, All Rights Reserved.

def map_ports(ss_string)
  fields = ss_string.split
  port = fields[3].split(':').last
  return nil if port == 'Local'
  service = fields[5]
            .split(':')
            .last.split(/\(\(|\)\)/)[1].split(',').first[1..-2]
  [port, service]
end

openports_v4 = shell_out('ss --ipv4 -nltep').stdout.each_line.map do |t|
  map_ports(t)
end.compact

openports_v6 = shell_out('ss --ipv6 -nltep').stdout.each_line.map do |t|
  map_ports(t)
end.compact

services = {
  sshd: {
    control: '08.07:001 Run SSH',
    port: 22
  }
}

control_group '02 Services' do
  services.each do |daemon, svc|
    control "#{svc[:control]} on port #{svc[:port]}" do
      it "is listening on port #{svc[:port]} (ipv4)" do
        ports = openports_v4.select { |(_, sv)| sv == daemon.to_s }
        ports.each { |p| openports_v4.delete p }
        expect(ports.size).to eq(1)
        expect(ports.first.first.to_i).to eq(svc[:port])
      end

      if openports_v6.size > 0
        it "is listening on port #{svc[:port]} (ipv6)" do
          ports = openports_v6.select { |(_, sv)| sv == daemon.to_s }
          ports.each { |p| openports_v6.delete p }
          expect(ports.size).to eq(1)
          expect(ports.first.first.to_i).to eq(svc[:port])
        end
      end
    end
  end
end

control_group '99 Open Ports' do
  control 'Open ports must be bound to an authorized service' do
    it 'is only listening on ports defined in 02 Services (ipv4)' do
      expect(openports_v4.size).to eq(0)
    end

    it 'is only listening on ports defined in 02 Services (ipv6)' do
      expect(openports_v6.size).to eq(0)
    end
  end
end
