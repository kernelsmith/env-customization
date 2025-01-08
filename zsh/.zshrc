# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# git completion
#source ~/git-completion.zsh

# Colors
autoload -U colors
colors
setopt prompt_subst

# Prompt
#PROMPT='
#%{$fg[blue]%}%~%{$reset_color%}
#%{$reset_color%}'

#RPROMPT='%{$fg_bold[grey]%} $(~/.rvm/bin/rvm-prompt)$(~/bin/git-cwd-info)%{$reset_color%}'

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="false"
DISABLE_UPDATE_PROMPT="false"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  git-lfs
  github
  bundler
  rake
  rbenv
  ruby
)
# plugins=($plugins ruby gem bundler rails)
# plugins=($plugins osx brew)
# plugins=($plugins linux)

source $ZSH/oh-my-zsh.sh

# User configuration
#
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
# export PKG_CONFIG_PATH="/usr/local/opt/libpq/lib/pkgconfig"

# SSH
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Universal aliases
#
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias ll='ls -lah'
alias dos2unix="sed 's/\r$//' $1 > $2"
alias timestamp="date +'%Y%m%d%H%M%S'"
alias datestamp="date +'%Y%m%d%H'"

# rails/rake aliases
#
# alias prime_db="rake db:drop db:create db:migrate dev:prime"
# alias assets="rails tmp:clear && rails assets:precompile; echo 'you may need to brew install yarn'"

# git/github (if not in ~/.gitconfig) aliases
#
# alias gho='GH_HOST=github.other gh'

# Universal functions
#
function fingerprint() { ssh-keygen -lf $1 -E sha256; }
function prep() { cd "$ZSH" && ls -l && git branch; }

# Depending on OS
#
if `uname |grep -q -i darwin`; then
  # MacOS-specific items

  plugins=($plugins osx brew macos)

  # brew aliases
  #
  alias brew_list_services="brew services list"
  alias brew_list_services_long="brew services list --debug"
  alias bsl="brew services list"
  alias bsll="brew services list --debug"
  # alias stop_postgres="brew services stop postgresql@14"
  # alias start_postgres="brew services start postgresql@14"
  # alias restart_postgres="brew services restart postgresql@14"
  # if you don't want/need a background service you can just run:
  # /usr/local/opt/redis/bin/redis-server /usr/local/etc/redis.conf
  # alias stop_redis="brew services stop redis"
  # alias start_redis="brew services start redis"
  # alias restart_redis="brew services restart redis"

  # search/find aliases
  #
  alias mf="mdfind -name "

  # Functions
  #
  function cap() {
    screencapture -l$(osascript -e 'tell app "iTerm" to id of window 1') $ZSH/themes/$ZSH_THEME.png
  }
  function umount() { diskutil unmount $1; }

else
  # Unix/Linux-specific items

  plugins=($plugins linux)

  # search/find aliases
  #
  alias mf="find . -iname *$1*"

fi

