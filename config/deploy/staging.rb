# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{root@192.168.100.155}
role :web, %w{root@192.168.100.155}
role :db,  %w{root@192.168.100.155}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

ask(:password, "VsIs@987", echo: false)
server '192.168.100.155', user: 'root', password: fetch(:password), roles: %w{web app db}#, my_property: :my_value

set :rvm_ruby_version, "ruby-2.3.8@rails_4_2_1"
set :rvm_type, :system
set :deploy_to, '/var/www/inova-crm'

set :rails_env, 'staging'

set :branch, "staging"

# set :whenever_environment, 'staging'
# set :whenever_command, 'bundle exec whenever'

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# Otherwise assets cannot be accessed due to permission issues
namespace :deploy do
  before :finished, :public_temp do
    on roles :web do
    	# within current_path do
    	# 	puts current_path
    	# end
      within current_path do
        execute "cd #{current_path}/public && mkdir uploads"
        execute "cd #{current_path}/public && chmod o+w,g+w -R uploads"
        execute :chmod, 'o+w,g+w', '-R', 'tmp'
        execute :chmod, 'o+w,g+w', '-R', 'log'
      end
    end
  end

  # after :finishing, 'deploy:update_cron'
end