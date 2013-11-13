INTERACTIVE LOGIN SHELL
(typically when you login at the console (Ctrl+Alt+F2 etc) or SSH
  You can check if your Bash shell is started as a login-shell by running:
  shopt login_shell # on = login shell

--STARTUP Execution Sequence:

execute /etc/profile
then execute the FIRST of the following which exists and is readable
~/.bash_profile # which often sources ~/.bashrc
~/.bash_login
~/.profile

In pseudo-code, this might look like:
Execute /etc/profile
IF ~/.bash_profile exists THEN
    execute ~/.bash_profile # which you should have source ~/.bashrc, see below
ELSE
    IF ~/.bash_login exist THEN
        execute ~/.bash_login
    ELSE
        IF ~/.profile exist THEN
            execute ~/.profile
        END IF
    END IF
END IF

If none of the above are triggered, bash stops looking for . files and gives a prompt
Since .bashrc is not read by default in the above situation, you should have,
depending on your exact situation, .bash_profile source ~/.bashrc (somewhere near the end)

--LOGOUT Execution Sequence:

IF ~/.bash_logout exists THEN
    execute ~/.bash_logout
END IF

INTERACTIVE NON-LOGIN SHELL
(typically when you open a terminal from the GUI)

--STARTUP Execution Sequence:

Lookup and execute file name stored in ENV variable, typically $HOME/.bashrc
IF ~/.bashrc exists THEN
    execute ~/.bashrc # typically sources /etc/bashrc if it exists
END IF

# For more information:
Excerpt from man bash:

When bash is invoked as an interactive login shell, or as a non-interactive shell
with the --login option, it first reads and executes commands from the file /etc/profile,
if that file exists. After reading that file, it looks for ~/.bash_profile, ~/.bash_login,
and ~/.profile, in that order, and reads and executes commands from the first one that
exists and is readable." 
su does not start a login shell by default, you can force it with -l or --login.
