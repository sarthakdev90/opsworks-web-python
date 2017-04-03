#
# Cookbook Name:: opsworks_deploy_python
# Recipe:: default
#
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
