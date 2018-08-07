# Rails: Save My Tabs

## Table Of Contents

1. Introduction
1. Development Setup
1. Testing Setup

## Introduction

The Save My Tabs Rails web API provides a simple storage for web addresses and
descriptive titles. The web application supports JWT authentication.

## Development Setup

To run the development environment, you must have Docker and Docker-Compose
installed in your system.

```
git clone https://github.com/LySofDev/rails-save-my-tabs.git
cd rails-save-my-tabs
docker-compose build
docker-compose up
```

The development server will listen on port 3000 by default.

## Testing Setup

To run the test environment, you must first have the Development Setup completed.

```
docker-compose down
docker-compose run web /bin/ash
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec guard
all rspec
```
