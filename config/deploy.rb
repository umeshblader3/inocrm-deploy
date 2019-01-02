# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'inova-crm'
# set :repo_url, 'git@git.assembla.com:inova-crm.git'
# set :repo_url, 'git@bitbucket.org:umesh_m/inova-crm.git'
set :repo_url, 'git@github.com:Romitha/inocrm.git'

#configure rvm in server
# set :rvm_type, :user
# set :rvm_type, :system

# set :rvm_ruby_version, 'ruby-2.1.2@inovacrm412'
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, "master"

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/home/dev/rails_project/inova-crm'
# set :deploy_to, '/home/pro/rails_project/inova-crm'

# deploy via git copy
# set :forward_agent, true
set :deploy_via, :remote_cache

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   # execute :rake, 'cache:clear'
      #   puts fetch(:set_rails_env)
      # end
    end
  end

  desc "Uploads database.yml to remote servers."
  task :upload_database_config do
    on roles(:all) do
      # execute "cd #{shared_path} && mkdir config"
      upload!("config/database.yml", "#{shared_path}/config/database.yml")
    end
  end

  desc "seeding initial data"
  task :seed_data do
    on roles(:web), in: :groups, limit: 3, wait: 10 do 
      within current_path do
        execute :rake, "db:seed RAILS_ENV=#{fetch(:rails_env)} --trace"
      end
    end
  end

  desc "bootstrap database for fresh data"
  task :bootstrap_data do
    on roles(:web), in: :groups, limit: 3, wait: 10 do 
      within current_path do
        execute :rake, "db:bootstrap RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  task :flush_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do 
      within current_path do
        execute :rake, "clear_dalli_cache RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  desc "Indexing..."
  task :index_model do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        execute :rake, "environment tire:deep_import CLASS=#{ENV['model']} PCLASS=#{ENV['pmodel']} FORCE=true RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  desc "Re-indexing available models"
  task :index_all_model do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        # [['Grn'], ['GrnItem', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['Product'], ['Ticket'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization']].each do |models|
        #   execute :rake, "environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true RAILS_ENV=#{fetch(:rails_env)}"
        # end

        execute :rake, "tire:index_all_model RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  desc ""
  task :upload_printer_template do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        # [['Grn'], ['GrnItem', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['Product'], ['Ticket'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization']].each do |models|
        #   execute :rake, "environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true RAILS_ENV=#{fetch(:rails_env)}"
        # end

        execute :rake, "upload_printer_template RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  # desc "update database"
  # task :migrate do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do 
  #     within current_path do
  #       execute :rake, "db:migrate RAILS_ENV=#{fetch(:rails_env)}"
  #     end
  #   end
  # end

  # before 'assets:backup_manifest', 'assets:create_manifest_json' do
  #   on roles :web, in: :groups, limit: 3, wait: 10 do
  #     within release_path do
  #       execute :mkdir, release_path.join('assets_manifest_backup')
  #       execute :chmod, 'a+w -R', 'assets_manifest_backup'
  #     end
  #   end
  # end
  # before 'assets:backup_manifest', :ignore_rvm_warning do
  #   on roles :web, in: :groups, limit: 3, wait: 10 do
  #     within release_path do
  #       execute 'rvm rvmrc warning ignore #{release_path}/Gemfile'
  #     end
  #   end
  # end

  # task :test do
  #   on release_roles(fetch(:assets_roles)) do
  #     within shared_path do
  #       candidate = shared_path.join('public', fetch(:assets_prefix), ".sprockets-manifest*")
  #       puts capture(:ls, candidate).strip.gsub(/(\r|\n)/,' ') if test(:ls, candidate)
  #     end
  #   end
  # end

  before 'assets:precompile', :set_rvm_ignore_warning do
    on roles :web, in: :groups, limit: 3, wait: 10 do # (fetch(:rvm_roles, :all))
      within release_path do
        execute 'rvm rvmrc warning ignore allGemfiles'
        # execute 'rvm rvmrc warning ignore all.rvmrcs'
      end
    end
  end

  # before :set_current_path do
  #   on roles :web, in: :groups, limit: 3, wait: 10 do # (fetch(:rvm_roles, :all))
  #     execute "ln -s /home/dev/rails_project/inova-crm/release /home/dev/rails_project/inova-crm/current"
  #   end
  # end

  task :live_log do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        execute :tail, '-f', "log/#{fetch(:rails_env)}.log"
      end
    end
  end

  desc "Remote console"
  task :console do
    on roles :web, in: :groups, limit: 3, wait: 10 do
      within current_path do
        execute "bundle exec rails console #{fetch(:rails_env)}"
      end
    end
  end

  desc "Seed Roles Permissions"
  task :seed_roles_permissions do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        execute :rake, "seed_roles_permissions RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  # before :finished, :restart_server do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     within current_path do
  #       execute :sudo, :service, :nginx, :reload
  #     end
  #   end
  # end

  # task :update_cron do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     within current_path do
  #       # command "mysqldump -uroot -pmysql --skip-triggers --compact --no-create-info inocrm_dev > #{path}/timestamp_`date +\%Y\%m\%d\%H\%M\%S`.sql"
  #       # Visit http://dev.mysql.com/doc/refman/5.7/en/mysqldump.html for more argument info
  #       # command "/Users/umeshblader/Projects/git/Dropbox-Uploader/dropbox_uploader.sh upload "
  #       # rake "flush_logfile -- -p='#{shared_path}' -s='production' "

  #       execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)}"
  #     end
  #   end
  # end

  task :flush_logfile do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within current_path do
        # https://www.sitepoint.com/schedule-cron-jobs-whenever-gem/ for more...
        execute :rake, "flush_logfile -- -p '#{shared_path}' -s '#{fetch(:rails_env)}' "

        # execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)}"
      end
    end
  end

end