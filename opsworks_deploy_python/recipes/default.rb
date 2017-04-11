#
# Cookbook Name:: opsworks_deploy_python
# Recipe:: default
#

# include_recipe 'poise-python'
# include_recipe 'apt::default'
# include_recipe 'gunicorn'

node[:deploy].each do |application, deploy|
  Chef::Log.info "Application is #{application}"
  Chef::Log.info "Custom type is #{deploy["custom_type"]}"
#   if deploy["custom_type"] != 'python'
#     next
#   end
#   python_base_setup do
#     deploy_data deploy
#     app_name application
#   end

#   python_base_deploy do
#     deploy_data deploy
#     app_name application
#   end
# node[:deploy].each do |application, deploy|

  # Chef::Log.info "Installing Pip"
  # easy_install_package 'pip' do
  #   module_name 'pip'
  #   action :install
  # end

  # python_runtime '2'
  # python_virtualenv '/.virtualenvs/test/'

  # Chef::Log.info "Installing Django"
  # python_package 'Django' do
  #   version '1.8'
  # end


  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_custom_deploy do
    deploy_data deploy
    app application
  end
end
