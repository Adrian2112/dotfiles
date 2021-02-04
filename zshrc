# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agonz"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git vi-mode history-substring-search)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/git/bin:$PATH

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PORT=3000

DYLD_LIBRARY_PATH="/usr/local/mysql/lib:$DYLD_LIBRARY_PATH"

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^R' history-incremental-search-backward

PATH=/usr/local/bin:$PATH

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# prevent closing window with ctrl-d
set -o ignoreeof
export GIT_PAGER="less -F -X" # tell less not to paginate if less than a page

# load other zshrc configs
test -f ~/.zshrc_* && source ~/.zshrc_*

export FZF_DEFAULT_COMMAND="rg --no-ignore-exclude --files --colors 'match:bg:yellow' --colors 'match:fg:black' --colors 'match:style:nobold' --colors 'path:fg:green' --colors 'path:style:bold' --colors 'line:fg:yellow' --colors 'line:style:bold'"

# direnv to load .envrc to ENV
eval "$(direnv hook zsh)"

export PYTHONSTARTUP=$HOME/.pythonstartup.py

# delete squash merged branches
# https://github.com/not-an-aardvark/git-delete-squashed#sh
g_delete_squash_merged() {
  main_branch=`git remote show origin | grep "HEAD branch" | awk '{print $3}'`
  merged_branches=`git checkout -q $main_branch && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base $main_branch $branch) && [[ $(git cherry $main_branch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] && echo "$branch"; done`
  echo $merged_branches && echo '\ndelete?' && read && echo $merged_branches | xargs -n 1 git branch -D
  unset main_branch
  unset merged_branches
}

# delete merged branches
g_delete_merged() {
  main_branch=`git remote show origin | grep "HEAD branch" | awk '{print $3}'`
  git branch --merged $main_branch | grep -v '\(master\|\*\|develop\)' | xargs -n 1 echo && echo '\ndelete?' && read && git branch --merged $main_branch | grep -v '\(master\|\*\|develop\)' | xargs -n 1 git branch -d
}
