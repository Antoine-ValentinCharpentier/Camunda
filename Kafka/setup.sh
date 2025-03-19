#!/bin/bash

helm install my-release oci://registry-1.docker.io/bitnamicharts/kafka --version 31.5.0 -f values-kafka.yml -n tdf-integration-infra

