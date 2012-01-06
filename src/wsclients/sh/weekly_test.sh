#!/bin/bash

touch /local/epept/epept_pinged_$(date +%Y%m%d).dat
echo ping done $(date +%Y%m%d)
cd /local/epept/ws
ruby EPEPT_AddamaWSClientCron.rb
