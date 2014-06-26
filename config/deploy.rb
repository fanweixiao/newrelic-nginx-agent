# config valid only for Capistrano 3.1
lock "3.2.1"

set :application, "newrelic_nginx_agent"
set :repo_url,    "git@github.com:crowdlab-uk/newrelic-nginx-agent.git"
set :ssh_options,  { forward_agent: true, user: "deploy" }
set :deploy_to,    "/apps/newrelic_nginx_agent"
set :linked_files, %w(config/newrelic_plugin.yml)
set :log_level,    :info

set :rvm_type, :user
set :rvm_ruby_version, "ruby-2.1.2@newrelic_nginx"

namespace :agent do
  def daemon(*actions)
    on roles(:app), in: :sequence, wait: 5 do
      within(current_path) do
        actions.each do |action|
          execute :bundle, :exec, :"./newrelic_nginx_agent.daemon", action
        end
      end
    end
  end

  desc "Start agent"
  task :start do
    daemon(:start)
  end

  desc "Stop agent"
  task :stop do
    daemon(:stop)
  end

  desc "Restart agent"
  task :restart do
    daemon(:stop, :start)
  end

  desc "Status of agent"
  task :status do
    on roles(:app), in: :sequence do |server|
      within(current_path) do
        status = capture(:bundle, :exec, :"./newrelic_nginx_agent.daemon", :status)
        info "[#{server.hostname}] #{status}"
      end
    end
  end
end

namespace :deploy do
  after :publishing, "agent:restart"
end
