#!/bin/bash

docker ps --format 'table {{.Image}}\t{{.Ports}}' | grep -- '-c9'
