## MOD Vehicles Uploader

### Dependencies
* Ruby 2.6.3
* Ruby on Rails 6.0
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

Configures various linters to comply with GOV.UK's style guides.
```
govuk-lint-sass app/javascript
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
