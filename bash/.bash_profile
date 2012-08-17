SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"
    	  if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
          	eval `$SSHAGENT $SSHAGENTARGS`
    	  	trap "kill $SSH_AGENT_PID" 0
    	  fi

# Do some X stuff

read -N 1 -p "Press any key within 5 seconds to abort automatic startx" -t 5 -s
echo
if [ -z "$REPLY" ]; then echo "Starting X" && startx;fi

