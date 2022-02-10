#!/bin/bash

set -x
set -e

if [ $# -ne 1 ]
then
    echo "Expected one parameter: path to executable."
    exit 1
fi

CHERIBSD_PORT=10086
CHERIBSD_USER=root
CHERIBSD_HOST=localhost
SSH_OPTIONS='-o "StrictHostKeyChecking no"'
SCP_OPTIONS='-o "StrictHostKeyChecking no"'

scp $SCP_OPTIONS -P $CHERIBSD_PORT $1 $CHERIBSD_USER@$CHERIBSD_HOST:
ssh $SSH_OPTIONS -p $CHERIBSD_PORT $CHERIBSD_USER@$CHERIBSD_HOST -t ./$(basename $1)
