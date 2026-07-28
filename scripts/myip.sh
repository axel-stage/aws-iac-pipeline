#!/bin/bash
set -e

current_public_ipv4=$(curl https://checkip.amazonaws.com)
echo {\"ipv4\":\"${current_public_ipv4}\"}