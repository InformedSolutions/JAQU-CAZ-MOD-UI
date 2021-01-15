## MOD Vehicles Uploader

[![Build Status](http://drone-1587293244.eu-west-2.elb.amazonaws.com/api/badges/InformedSolutions/JAQU-CAZ-MOD-UI/status.svg?ref=refs/heads/develop)](http://drone-1587293244.eu-west-2.elb.amazonaws.com/InformedSolutions/JAQU-CAZ-MOD-UI)

### Dependencies
* Ruby 2.7
* Ruby on Rails 6
* [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
* Other packages listed in Gemfile and package.json files.

### RSpec test
```
rspec
```

### Cucumber test
```
cucumber
```

### Linting
A Ruby static code analyzer and formatter.
```
rubocop
```

Configurable tool for writing clean, consistent SCSS.
```
scss-lint app/javascript
```

### SonarQube inspection
```
sonar-scanner
```

### Variables

* Create .env configuration file from example config.
```
cp .env.example .env
```

* Enter local credentials for database, google analytics etc.:
```
nano .env
```
