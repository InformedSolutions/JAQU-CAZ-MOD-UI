copy-source:
	mkdir -p ~/src
	rsync -av --progress /vagrant/. ~/src --exclude node_modules

run:
	gem install bundler --version=2.0.2
	mkdir -p ~/src
	rsync -av --progress /vagrant/. ~/src --exclude node_modules
	cd ~/src; bundle install; yarn install; rails server

unit-test:
	yarn install
	rspec -f d
	
scenario-test:
	yarn install
	cucumber

install-sonar-scanner:
	wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip
	unzip -o sonar-scanner-cli-3.2.0.1227-linux.zip
	chmod +x sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner
	
launch-sonarqube:
	docker run -d --name sonarqube -p 9000:9000 sonarqube
	
stop-sonarqube:
	docker stop sonarqube
	
install-sonar-stack: install-sonar-scanner launch-sonarqube
	
sonar-scan:
	sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.user=admin -Dsonar.password=admin
