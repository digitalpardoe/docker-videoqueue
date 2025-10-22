#!/bin/bash

set -e

bundle exec puma -w 0 -p 4567 -e production
