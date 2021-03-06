# License: GPL v3
# Author: Matheus Souza Fernandes (2014)
# Receita de configuração do Sonar Runner para o Radar Parlamentar

user = node['radar']['linux_user']
home = "/home/#{user}"
repo_folder = "#{home}/radar/repo"
venv_folder = "#{home}/radar/venv_radar"
sonar_version = node['sonarqube']['version']

template "/opt/sonarqube-#{sonar_version}/conf/sonar.properties" do
  mode '0644'
  source "sonar.properties.erb"
  variables({
    :user => node["sonarqube"]["user"],
    :password => node["sonarqube"]["password"],
    :port => node["sonarqube"]["port"]
  })
end

remote_file "/opt/sonarqube-#{sonar_version}/extensions/plugins/sonar-python-plugin-1.3.jar" do
  source "http://repository.codehaus.org/org/codehaus/sonar-plugins/python/sonar-python-plugin/1.3/sonar-python-plugin-1.3.jar"
  action :create_if_missing
end


remote_file "#{home}/sonar-runner.zip" do
  source "http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip"
  action :create_if_missing
end

execute "unzip sonnar-runnser" do
  command "unzip -u sonar-runner.zip -d /opt/"
  cwd "#{home}"
  action :run
end


template "/opt/sonar-runner-2.4/conf/sonar-runner.properties" do
  mode '0644'
  source "sonar-runner.properties.erb"
  variables({
    :user => node["sonarqube"]["user"],
    :password => node["sonarqube"]["password"],
    :port => node["sonarqube"]["port"]
  })
end

template "#{repo_folder}/radar_parlamentar/sonar-runner.sh" do
  mode '0644'
  source "sonar-runner.sh.erb"
  variables({
    :coverage => "#{venv_folder}/bin/coverage",
    :venv => "#{venv_folder}"
  })
end

execute "sonar-runner" do
  command "bash sonar-runner.sh"
  cwd "#{repo_folder}/radar_parlamentar"
  user "#{user}"
  action :run
end
