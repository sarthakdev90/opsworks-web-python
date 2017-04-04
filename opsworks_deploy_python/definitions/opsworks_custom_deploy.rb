define :opsworks_custom_deploy do
  application = params[:app]
  deploy = params[:deploy_data]

  Chef::Log.info "Deploy directory is #{deploy[:deploy_to]}"

  directory "#{deploy[:deploy_to]}" do
    group deploy[:group]
    owner deploy[:user]
    mode "0775"
    action :create
    recursive true
  end

  # directory "/data/helpkit/assets" do
  #   action :create 
  #   not_if do ::File.directory?('/data/helpkit/assets') end
  # end
  
  if deploy[:scm]
    ensure_scm_package_installed(deploy[:scm][:scm_type])

    prepare_git_checkouts(
      :user => deploy[:user],
      :group => deploy[:group],
      :home => deploy[:home],
      #:ssh_key => deploy[:scm][:ssh_key]
    ) if deploy[:scm][:scm_type].to_s == 'git'
  end

  deploy = node[:deploy][application]

  Chef::Log.info "Deploy var is #{deploy}"

  directory "#{deploy[:deploy_to]}/shared/cached-copy" do
    recursive true
    action :delete
    only_if do
      deploy[:delete_cached_copy]
    end
  end

  # ruby_block "change HOME to #{deploy[:home]} for source checkout" do
  #   block do
  #     ENV['HOME'] = "#{deploy[:home]}"
  #   end
  # end

  # setup deployment & checkout
  if deploy[:scm] && deploy[:scm][:scm_type] != 'other'
    Chef::Log.debug("Checking out source code of application #{application} with type #{deploy[:application_type]}")

    git 'django-admin' do
      repository deploy[:scm][:repository]
      user deploy[:user]
      group deploy[:group]
      revision deploy[:scm][:revision]
      destination '/tmp/chef-code'
      action :checkout
    end

    # deploy deploy[:deploy_to] do
    #   provider Chef::Provider::Deploy.const_get(deploy[:chef_provider])
    #   # if deploy[:keep_releases]
    #   #   keep_releases deploy[:keep_releases]
    #   # end
    #   repository deploy[:scm][:repository]
    #   user deploy[:user]
    #   group deploy[:group]
    #   revision deploy[:scm][:revision]
    #   #migrate deploy[:migrate]
    #   #migration_command deploy[:migrate_command]
    #   environment deploy[:environment].to_hash
    #   #symlink_before_migrate({})
    #   #action deploy[:action]

    #   # if node[:opsworks][:instance][:hostname].include?("-app-")
    #   #   restart_command "sleep #{deploy[:sleep_before_restart]} && sudo /etc/init.d/nginx restart"
    #   # end

    #   scm_provider :git
    #   enable_submodules deploy[:enable_submodules]
    #   shallow_clone deploy[:shallow_clone]
      
      #Chef::Log.info "Core count of instance is  #{node[:core][:count]} " 

    #   before_migrate do
    #     link_tempfiles_to_current_release
    #   	bash "bundler run helpkit" do
				# 	user "deploy"
				# 	cwd release_path
				# 	code "bundle install --without=#{deploy[:ignore_bundler_groups].join(' ')} --path='#{deploy[:deploy_to]}/shared/bundler_gems'"
				# end

    #     # OpsWorks::RailsConfiguration.bundle(application, node[:deploy][application], release_path)
    #     # run user provided callback file
    #     run_callback_from_file("#{release_path}/deploy/before_migrate.rb")
    #     #run_callback_from_file("#{release_path}/deploy/before_symlink.rb")
    #   end
    # end
  end

  # ruby_block "change HOME back to /root after source checkout" do
  #   block do
  #     ENV['HOME'] = "/root"
  #   end
  # end

  # unless ["rails3_email","rails3_app","resque","rails3_reports","rails3_search","rails3_solution","rails3_support","rails3_support_theme"].include?(node[:opsworks][:instance][:layers].first)
  #   template "/etc/logrotate.d/opsworks_app_#{application}" do
  #     backup false
  #     source "helpkit.logrotate.erb"
  #     cookbook 'deploy'
  #     owner "root"
  #     group "root"
  #     mode 0644
  #     variables( :log_dirs => ["#{deploy[:deploy_to]}/shared/log" ] )
  #   end
  # end
end