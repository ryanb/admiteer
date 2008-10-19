set :application, "admiteer"
set :resolve, '70.85.129.132'
set :repository,  "https://svn.railsrumble.com/admiteer/trunk"
set :user, 'www'
set :deploy_to, "/www/#{application}"

role :app, resolve
role :web, resolve
role :db,  resolve, :primary => true

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# =============================================================================
# RECIPES
# =============================================================================


namespace :deploy do

  # we're using mongrel cluster so bypass calls to /script/spawner

  [ :stop, :start, :restart ].each do |t|
    desc "#{t} Mongrel::Cluster"
    task t, :roles => :app do
      run "cd #{current_path} && mongrel_rails cluster::#{t} -C #{mongrel_conf}"
    end
  end

  desc "Symlink the proper database.yml and the graphics folder"
  task :after_symlink do
    run "rm -f #{current_path}/config/database.yml && ln -s #{current_path}/config/database.production.yml #{current_path}/config/database.yml"
    run "ln -s #{shared_path}/graphics #{current_path}/public/graphics"
  end
  
  desc "run deploy:update, deploy:migrate, deploy:restart"
  task :full do
    update
    migrate
    restart
    cleanup
  end
  
end

desc "remotely console" 
task :console, :roles => :app do
  puts "********************************"
  puts "Are you absolutely sure you need to do this?"
  puts "Only use the production console in an emergency!"
  puts "Make sure you back up all data first!"
  puts "********************************"
  input = ''
  run "cd #{current_path} && ruby ./script/console #{ENV['RAILS_ENV']}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end
