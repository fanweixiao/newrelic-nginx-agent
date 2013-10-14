require "bundler/capistrano"
require "rvm/capistrano"
require "rvm/capistrano/alias_and_wrapp"

set :application, "newrelic_nginx_agent"

set :scm, :git
set :repository,     "git@github.com:crowdlab-uk/newrelic-nginx-agent.git"
set :ssh_options,    { forward_agent: true }
set :scm_username,   "app_user@crowdlab.com"
set :deploy_to,      "/apps/newrelic_nginx_agent"
set :deploy_via,     :remote_cache
set :keep_releases, 3
set :normalize_asset_timestamps, false

server "head01.allchannelsopen.com", :web, :app
server "tail01.allchannelsopen.com", :web, :app

set :use_sudo, false
set :user,     "monitor"
set :group,    "monitor"

set :rvm_ruby_string, :local
set :rvm_autolibs_flag, "read-only"

before "deploy:setup", "rvm:install_rvm"
before "deploy:setup", "rvm:install_ruby"

before "deploy", "rvm:create_alias"
before "deploy", "rvm:create_wrappers"

logger.level = Capistrano::Logger::DEBUG

after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  def daemon(*actions)
    commands = []
    commands << "cd #{current_path}"
    actions.each do |action|
      commands << "bundle exec ruby newrelic_nginx_agent.daemon #{action}"
    end
    run commands.join(" && ")
  end

  task :start do
    daemon(:start)
  end
  task :stop do
    daemon(:stop)
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    daemon(:stop, :start)
  end
  task :status do
    daemon(:status)
  end
end



task :create_symlink_to_env_variables do
  run "ln -s #{shared_path}/newrelic_plugin.yml #{release_path}/config"
end
after "deploy:finalize_update", :create_symlink_to_env_variables
