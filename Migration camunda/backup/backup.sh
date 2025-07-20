#!/bin/bash

export BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
export RELEASE_NAME="camunda-platform"

./backup-openshift-conf.sh
./backup-data.sh