fpath=(~/.local/share/zsh/site-functions $fpath)
fpath=(~/.oh-my-zsh/completions $fpath)
fpath=(~/.zsh/completion $fpath)

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -Uz compinit && compinit

# blender setup
export PATH="$PATH:/Applications/Blender.app/Contents/MacOS"
# End blender setup

[[ -x ~/.local/bin/mise ]] && eval "$(~/.local/bin/mise activate zsh)"

# cargo setup
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# End cargo setup

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# LM Studio CLI (lms)
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

# starship init
command -v starship &>/dev/null && eval "$(starship init zsh)"

# aliases (macOS only)
[[ "$OSTYPE" == "darwin"* ]] && alias chrome='osascript -e "tell application \"Google Chrome\" to make new window"'

if command -v eza &>/dev/null; then
  alias ls='eza --icons=auto --git --git-repos --group-directories-first --sort=name --time-style=long-iso -h --hyperlink -F always'
  alias ll='ls -la'
  alias lt='ls -T'
fi
# End aliases