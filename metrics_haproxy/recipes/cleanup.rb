# metrics_haproxy/recipes/cleanup.rb

# Remove HAProxy container
docker_container 'haproxy' do
    action :stop
  end
  
  docker_container 'haproxy' do
    action :remove
  end
  
  # Remove metrics collector container
  docker_container 'metrics_collector' do
    action :stop
  end
  
  docker_container 'metrics_collector' do
    action :remove
  end
  
  # Remove images
  docker_image 'prom/node-exporter' do
    action :remove
  end
  
  docker_image 'pankaj2212/docker-challenge' do
    action :remove
  end
  
  # Remove network
  docker_network 'metrics_network' do
    action :remove
  end
  
  # Remove configuration files if needed
  file '/opt/haproxy/haproxy.cfg' do
    action :delete
  end
  