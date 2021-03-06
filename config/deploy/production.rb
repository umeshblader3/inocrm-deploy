# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{root@192.168.1.146}
role :web, %w{root@192.168.1.146}
role :db,  %w{root@192.168.1.146}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

# ask(:password, "centos", echo: false)
# server '192.168.1.146', user: 'root', password: fetch(:password), roles: %w{web app db}#, my_property: :my_value

# server '192.168.1.146', user: 'root', password: "centos", roles: %w{web app db}#, my_property: :my_value
server "#{ENV['server']}", user: "#{ENV['user']}", password: "#{ENV['password']}", roles: %w{web app db}#, my_property: :my_value

set :rvm_ruby_version, "ruby-2.3.8@rails_4_2_1"
set :rvm_type, :user
set :deploy_to, '/var/www/inova-crm'

set :whenever_roles, ->{ [:web, :app]}
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