#!/bin/bash
set -xe

export NEXUS_URL=$1
export NEXUS_USERNAME=$2
export NEXUS_PASSWORD=$3
export CASE_PARAM=$4

cd nexus-e2e
python -m pytest --alluredir ../allure-results $CASE_PARAM
