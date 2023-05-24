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
plugins=(vi-mode history-substring-search)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/git/bin:$PATH

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PORT=3000

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^R' history-incremental-search-backward

PATH=/usr/local/bin:$PATH

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# prevent closing window with ctrl-d
set -o ignoreeof
#export GIT_PAGER="diff-so-fancy"
#export GIT_PAGER="less -F -X" # tell less not to paginate if less than a page

# load other zshrc configs
test -f ~/.zshrc_* && source ~/.zshrc_*

export FZF_DEFAULT_COMMAND="rg --no-ignore-exclude --files --colors 'match:bg:yellow' --colors 'match:fg:black' --colors 'match:style:nobold' --colors 'path:fg:green' --colors 'path:style:bold' --colors 'line:fg:yellow' --colors 'line:style:bold'"

# direnv to load .envrc to ENV
eval "$(direnv hook zsh)"

export PYTHONSTARTUP=$HOME/.pythonstartup.py

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adriangonzalez/Dev/InternalToolsCron/y/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adriangonzalez/Dev/InternalToolsCron/y/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adriangonzalez/Dev/InternalToolsCron/y/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adriangonzalez/Dev/InternalToolsCron/y/google-cloud-sdk/completion.zsh.inc'; fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# delete squash merged branches
# https://github.com/not-an-aardvark/git-delete-squashed#sh
g_delete_squash_merged() {
  current_branch=`git rev-parse --abbrev-ref HEAD`
  main_branch=`git remote show origin | grep "HEAD branch" | awk '{print $3}'`
  merged_branches=`git checkout -q $main_branch && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base $main_branch $branch) && [[ $(git cherry $main_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]] && echo "$branch"; done`
  echo $merged_branches && echo '\ndelete?' && read && echo $merged_branches | xargs -n 1 git branch -D
  git checkout $current_branch
  unset current_branch
  unset main_branch
  unset merged_branches
}
git config --global alias.delete-squashed '!f() { local targetBranch=${1:-main} && git checkout -q $targetBranch && git branch --merged | grep -v "\*" | xargs -n 1 git branch -d && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base $targetBranch $branch) && [[ $(git cherry $targetBranch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; true; done; }; f'

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

alias pf="fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"

export FORGIT_INSTALL_DIR=/Users/adriangonzalez/Dev/forgit
source $FORGIT_INSTALL_DIR/forgit.plugin.zsh
# FORGIT_NO_ALIASES=1
export PATH="$PATH:$FORGIT_INSTALL_DIR/bin"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export XDG_CONFIG_HOME="$HOME"

iphone_notify() {
  msg=${1:-done}
  curl -d $msg ntfy.sh/31c3e65947425c04dc2ed700d1f40ec1
}

EDITOR=vim

# add ??, gh? and git??
eval "$(github-copilot-cli alias -- "$0")"

