#
# Cookbook Name:: hello_chef_server
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
file "#{Chef::Config[:file_cache_path]}/hello.txt" do
  content 'Hello, Chef server!'
end

control_group "02 Services" do
  control "08.07:001 Only Run SSH" do
    it "Only runs ssh" do
      openports = %x{ss -nltp}.each_line.map do |t|
       fields = t.split
       fields[3].split(':').last
      end.reject { |n| n == 'Local' }.uniq
      expect(openports.size).to eq(1)
    end
  end
end
