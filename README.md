Docker image for PHP 7.1
========================

Provides a PHP 7.1 docker image based on our [Alpine Linux 3.7 base image](https://github.com/gmitirol/alpine37).

This image can be used as a base for the testing and deployment of PHP applications.

Included scripts:

| Script                       | Purpose                                                                    |
| --------------------------   | -------------------------------------------------------------------------- |
| `php-ext.sh`                 | Enables, disables or shows PHP extensions                                  |
| `php-extensions.sh`          | Provides helper functions for getting available and default PHP extensions |
| `setup-gitlab-token-auth.sh` | Configures git and composer authentication via GitLab CI token             |
| `setup-nginx.sh`             | Configures the built-in nginx web server                                   |

Included tools:

| Tool    | Description                      | Website                                       |
| ------- | ------------------------------   | --------------------------------------------- |
| `sami`  | Sami API documentation generator | https://github.com/FriendsOfPHP/Sami          |
| `phpcs` | PHP CodeSniffer                  | https://github.com/squizlabs/PHP_CodeSniffer/ |

For running the PHP applications, a locked default user `project` with UID 1000 is created.

To build the docker image, do not forget to adapt the base image version in `Dockerfile` where necessary.

Usage example (with custom GitLab server)
-----------------------------------------

```yaml
# .gitlab-ci.yml
stages:
  - test

test:
  stage: test
  image: gmitirol/alpine37-php71:v2
  artifacts:
    expire_in: 1 hour
    name: "$CI_PROJECT_PATH_SLUG-$CI_PIPELINE_ID"
    paths:
      - build/coverage
      - build/doc
  script:
    - php-ext.sh enable 'xdebug'
    - setup-gitlab-token-auth.sh "$CI_JOB_TOKEN" "gitlab.example.com"
    - composer install --no-progress
    - phpcs $CI_PROJECT_DIR/src $CI_PROJECT_DIR/tests --standard=PSR2
    - php vendor/bin/phpunit $CI_PROJECT_DIR/tests --coverage-text -vv --colors=never
    - sami update sami.php
  tags:
    - shared
```
