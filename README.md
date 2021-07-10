[![Build Status](https://travis-ci.com/Matt-Warnock/weatherAPI_app.svg?branch=main)](https://travis-ci.com/Matt-Warnock/weatherAPI_app)
[![Coverage Status](https://coveralls.io/repos/github/Matt-Warnock/weatherAPI_app/badge.svg?branch=master)](https://coveralls.io/github/Matt-Warnock/weatherAPI_app?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/c666d381261434f0c5ae/maintainability)](https://codeclimate.com/github/Matt-Warnock/weatherAPI_app/maintainability)
[![Depfu](https://badges.depfu.com/badges/7212a0bd0ba7eb3446e4307a9919c375/overview.svg)](https://depfu.com/github/Matt-Warnock/weatherAPI_app?project_id=24041)


# Readme

Weather information for various cites world-wide.


## Testing JavaScript in jasmine

Please run jasmine tests in either Chrome or Firefox browsers on a Mac or Linux OS in a local server.

Before running tests, specify the locale language and the TZ environment variables for your browser of choice:

### For Firefox:

* Download and Install the french locale packages:

  for Mac OS X:

  I'm not exactly sure what the code is, sorry!

  for Linux:

  ```bash
  sudo locale-gen fr_FR fr_FR.UTF-8 && echo "Success"

  sudo apt-get install firefox-locale-fr
  ```

* Start Firefox using this command:

  ```bash
  TZ="Australia/Melbourne" LC_ALL=fr_FR firefox -no-remote & bin/app
  ```

  (This should work on both Mac OS X and Linux)

### For Chrome:

* First, create a new empty directory for a separate Chrome user profile:

   ```bash
   mkdir ~/chrome-profile-weather-test
   ```

* Then, to start Chrome, use these commands:

   for Mac OS X:

   ```bash
   TZ="Australia/Melbourne" LANGUAGE=fr open -na "Google Chrome" --args "--user-data-dir=$HOME/chrome-profile-weather-test" & bin/app
   ```

   for Linux:

   ```bash
   TZ="Australia/Melbourne" LANGUAGE=fr google-chrome "--user-data-dir=$HOME/chrome-profile-weather-test" & bin/app
   ```

#### Run jasmine tests in local server:

* open the local server link:
```
http://localhost:4567/js/SpecRunner.html
```

## Badges

* Turn your repo ON in Travis (CI), in Coveralls (coverage status), codeclimate (maintainability), and depfu (dependency status).
* Update badges with your user/repo names.


## How to use this project

This is a Ruby project. Tell your Ruby version manager to set your local Ruby version to the one specified in the `Gemfile`.

For example, if you are using [rbenv](https://cbednarski.com/articles/installing-ruby/):

1. Install the right Ruby version:
  ```bash
  rbenv install < VERSION >
  ```
1. Move to the root directory of this project and type:
  ```bash
  rbenv local < VERSION >
  ruby -v
  ```

You will also need to install the `bundler` gem, which will allow you to install the rest of the dependencies listed in the `Gemfile` file of this project.

```bash
gem install bundler
rbenv rehash
```


### Folder structure

* `bin `: Executable files
* `lib `: Source files
* `spec`: Test files


### To initialise the project

```bash
bundle install
```


### To run the app

Make sure that the `bin/app` file has execution permissions:

```bash
chmod +x bin/app
```

Then just type:

```bash
bin/app
```

If this doesn't work you can always do:

```bash
bundle exec ruby bin/app
```

## Tests


### To run all tests


```bash
bundle exec rspec
```


### To run a specific file


```bash
bundle exec rspec path/to/test/file.rb
```


### To run a specific test

```bash
bundle exec rspec path/to/test/file.rb:TESTLINENUMBER
```


### To run rubocop

```bash
bundle exec rubocop
```


### To run all tests and rubocop

```bash
bundle exec rake
```


## License

[![License](https://img.shields.io/badge/mit-license-green.svg?style=flat)](https://opensource.org/licenses/mit)
MIT License
