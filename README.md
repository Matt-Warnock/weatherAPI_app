[![Build Status](https://travis-ci.com/Matt-Warnock/weatherAPI_app.svg?branch=main)](https://travis-ci.com/Matt-Warnock/weatherAPI_app)
[![Coverage Status](https://coveralls.io/repos/github/Matt-Warnock/weatherAPI_app/badge.svg?branch=master)](https://coveralls.io/github/Matt-Warnock/weatherAPI_app?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/c666d381261434f0c5ae/maintainability)](https://codeclimate.com/github/Matt-Warnock/weatherAPI_app/maintainability)
[![Depfu](https://badges.depfu.com/badges/7212a0bd0ba7eb3446e4307a9919c375/overview.svg)](https://depfu.com/github/Matt-Warnock/weatherAPI_app?project_id=24041)


# Readme

Weather information for various cites world-wide.


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
