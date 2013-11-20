These scripts form a framework for managing BASH configuration etc.  It is
modeled after the rc.d startup scripts and is slightly slanted towards git and
ruby.  However it's very easy to alter once you get the idea.

Basically:
In the general case, .bash_profile is executed which sources .bashrc if it
has not already been run.  .bash_profile will also source
load_drop_directories.rc which looks for a group of .d diretories and sources
any scripts found in those directories that start with 'S' and end in '.rc'.
To enable some debugging information, edit .bash_profile and uncomment the line:
export DEBUG_DOT_FILES="true".  You will then see file searches and loads etc.
This stuff is not ready for primetime, I haven't even written an "install" script
yet, so it's easiest to just do this:

```Bash
git clone https://github.com/kernelsmith/env-customization.git
ln -s ~/.bash_profile env-customization/bash/.bash_profile
ln -s ~/.bashrc env-customization/bash/.bashrc
ln -s ~/load_drop_directories.rc env-customization/bash/load_drop_directories.rc
for dropdir in $(ls env-customization/bash/*.d); do
  ln -s ~/$dropdir env-customization/bash/dropdir
done
mkdir ~/private.d # for your secret sauce, it will get loaded automatically
# put stuff in private.d, and don't forget to chmod them
chmod -R +ox ~/private.d # or whatever
```
and put any additional stuff you want to add in the various .d directories.
Generally speaking:
* bashrc.d for core bashrc-like stuff, prompt changes etc
* functions.d for, umm functions you want available to you & your shell
* aliases.d for, umm, aliases.
* private.d for stuff you wouldn't want out there, stuff I don't want on github
You can mix and match the .d dirs, there's nothing magical them or their names,
they are just organizational containers.

Obviously, with anythign like this, you should review the code so you are
assured it's not doing anything nefarious.

For Reference, BASH .config file load sequences:
================================================

Interactive Login Shell
--------------------------------
(typically when you login at the console (Ctrl+Alt+F2 etc) or SSH
  You can check if your Bash shell is started as a login-shell by running:
  shopt login_shell # on = login shell

* STARTUP Execution Sequence:

** Execute /etc/profile
** Then execute the FIRST of the following which exists and is readable
**** ~/.bash_profile # which often sources ~/.bashrc
**** ~/.bash_login
**** ~/.profile

*** In pseudo-code, this might look like:

```
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
```

If none of the above are triggered, bash stops looking for . files and gives a
prompt.  Since .bashrc is not read by default in the above situation, you might
want to add, depending on your exact situation, source ~/.bashrc somewhere near
the end of your .bash_profile

* LOGOUT Execution Sequence:

```
IF ~/.bash_logout exists THEN
    execute ~/.bash_logout
END IF
```

Interactive Non-Login Shell
--------------------------------
(typically when you open a terminal from the GUI)

* STARTUP Execution Sequence:

** Lookup and execute file name stored in ENV variable, typically $HOME/.bashrc

```
IF ~/.bashrc exists THEN
    execute ~/.bashrc # typically sources /etc/bashrc if it exists
END IF
```

For more information:
---------------------------------
Excerpt from man bash:

*When bash is invoked as an interactive login shell, or as a non-interactive
shell with the --login option, it first reads and executes commands from the
file /etc/profile, if that file exists. After reading that file, it looks for
~/.bash_profile, ~/.bash_login, and ~/.profile, in that order, and reads and
executes commands from the first one that exists and is readable."
su does not start a login shell by default, you can force it with -l or --login*
