#!/bin/bash

set -e

rake db:migrate
ruby app.rb
