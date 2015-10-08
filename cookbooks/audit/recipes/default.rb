#
# Cookbook Name:: audit
# Recipe:: default
#
# Copyright (c) 2015 The Rubyists, All Rights Reserved.

include_recipe 'audit::01_files'
include_recipe 'audit::02_services'
