# good ref http://www.symantec.com/connect/articles/ssh-port-forwarding

# from the host that needs to get out:

UNUSED_LOCAL_PORT=9999 # You will tell your app, an irc client here, to use localhost and this port to connect
ULTIMATE_DESTINATION=irc.feenode.net # where you want your app to be able to reach
ULTIMATE_DESTINATION_PORT=7000 # the port you want your app to be able to reach
SHELL_SERVER=kernelsmith # ssh config host OR someuser@shellserver where shellserver is an fqdn or ip

# in our case, we're simulating an ssh config host:
# cat ~/.ssh/config
# Host kernelsmith
#   Hostname fqdn.or.ip.com
#   User someuser
#   PreferredAuthentications publickey # optional, but good for putting in script
#   IdentityFile ~/.ssh/my_rsa # optional in this case, good if you have > 1, or rename your key file from default (id_rsa)

ssh -L $UNUSED_LOCAL_PORT:$ULTIMATE_DESTINATION:$ULTIMATE_DESTINATION_PORT $SHELL_SERVER
# just login (if not using keys) and as long as this ssh session is open, your tunnel is running
