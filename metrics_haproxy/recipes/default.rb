# metrics_haproxy/recipes/default.rb

# Include the Docker cookbook
#include_recipe 'docker'

docker_network 'metrics_network' do
  action :create
end

docker_image 'prom/node-exporter' do
  tag 'latest'
  action :pull
end

docker_container 'metrics_collector' do
  image 'prom/node-exporter:latest'
  network_mode 'metrics_network'
  action :run
end

# Create a directory for the HAProxy configuration
directory '/opt/haproxy' do
  action :create
end

# Create the HAProxy configuration file
file '/opt/haproxy/haproxy.cfg' do
  content <<-EOF
    global
        log /dev/log local0
        log /dev/log local1 notice
        chroot /var/lib/haproxy
        user haproxy
        group haproxy
        daemon
        pidfile /usr/local/etc/haproxy/haproxy.pid

    defaults
        timeout http-request 2000
        timeout queue 1000
        timeout check 2000
        timeout connect 2000
        timeout client 5000
        timeout server 5000
        log global
        option dontlognull
        option clitcpka
        option srvtcpka
        option tcpka
        unique-id-format %[uuid()]
        unique-id-header X-Request-ID
        log-format "%ci:%cp [%tr] %ft %b/%s %TR/%Tw/%Tc/%Tr/%Ta %ST %B %CC %CS %tsc %ac/%fc/%bc/%sc/%rc %sq/%bq %hr %hs %ID %{+Q}r"

    frontend http-in
        mode http
        option forwardfor
        bind *:80

        # ACL for routing metrics traffic
        acl metrics_path path_beg /metrics
        use_backend metrics if metrics_path

        # Default backend for web traffic
        default_backend webservers

    backend webservers
        mode http
        option httpchk GET /
        server localhost-01 localhost:8001
        server localhost-02 localhost:8002
        server localhost-03 localhost:8003

      backend metrics
          mode http
          server metrics_exporter metrics_collector:9100
  EOF
  action :create
end

docker_image 'pankaj2212/docker-challenge' do
  tag 'latest'
  action :pull
end
# Run the HAProxy container
docker_container 'haproxy' do
  image 'pankaj2212/docker-challenge:latest'
  port '80:80'
  volumes ['/opt/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg']
  network_mode 'metrics_network'
  action :run
end

