#!/bin/bash

sudo -i -u hadoop <<'EOF'

~/hadoop-3.4.0/sbin/start-yarn.sh

mapred --daemon start historyserver

EOF