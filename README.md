# Travis Secrets Setter [![Build Status](https://travis-ci.org/HackGT/travis-secrets-setter.svg?branch=master)](https://travis-ci.org/HackGT/travis-secrets-setter)

This is a simple script which can be called as a travis build.
It will take some enviroment variables of that job and set them into
all other build jobs. Feel free to fork and adjust this to your own needs.

## Set a new `TRAVIS_TOKEN`

```bash
gem install travis
travis login
travis encrypt TRAVIS_TOKEN=$(travis token) --add env.global
```
