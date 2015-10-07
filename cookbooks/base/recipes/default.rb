#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

ohai 'reload' do
  action :nothing
end

cookbook_file File.join(node[:ohai][:plugin_path], 'packages.rb') do
  source 'packages.rb'
  action 'create'
  notifies :reload, 'ohai[reload]', :immediate
end




