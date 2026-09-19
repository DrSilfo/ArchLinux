# 1. Powerlevel10k Instant Prompt (Debe ir al inicio del archivo)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Variables de entorno e historial
export _JAVA_AWT_WM_NONREPARENTING=1
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# Optimización del PATH (Elimina duplicados automáticamente)
typeset -U path
path=(
  $HOME/.local/bin
  /snap/bin
  /usr/sandbox
  /usr/local/sbin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  /sbin
  /bin
  $path
)

# 3. Opciones de Zsh y atajos de teclado (Keybindings)
setopt histignorealldups sharehistory hist_ignore_space
bindkey -e

bindkey "^[[H"    beginning-of-line
bindkey "^[[F"    end-of-line
bindkey "^[[3~"   delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# 4. Sistema de autocompletado optimizado (Compinit)
autoload -Uz compinit
# Revisa actualizaciones de autocompletado solo 1 vez al día para acelerar el inicio de la terminal
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m+1) ]]; then
  compinit
else
  compinit -C
fi

# Estilos de autocompletado
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# 5. Alias de comandos
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'

# 6. Funciones personalizadas
function mkt(){
	mkdir -p {nmap,content,exploits,scripts}
}

# Extracción de puertos de Nmap (Procesamiento directo en memoria)
function extractPorts(){
	local file="$1"
	if [[ ! -f "$file" ]]; then
		echo -e "\n[!] El archivo '$file' no existe.\n"
		return 1
	fi

	local ports="$(grep -oP '\d{1,5}/open' "$file" | awk -F'/' '{print $1}' | xargs | tr ' ' ',')"
	local ip_address="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' "$file" | sort -u | head -n 1)"

	if [[ -n "$ports" ]]; then
		echo -e "\n[*] Extracting information...\n"
		echo -e "\t[*] IP Address: $ip_address"
		echo -e "\t[*] Open ports: $ports\n"
		echo -n "$ports" | xclip -sel clip
		echo -e "[*] Ports copied to clipboard\n"
	else
		echo -e "\n[!] No se encontraron puertos abiertos en el archivo.\n"
	fi
}

# Configuración de objetivo HTB
function settarget(){
  local ip_address=$1
  local machine_name=$2
  mkdir -p "$HOME/.config"
  echo "$ip_address $machine_name" > "$HOME/.config/htbtarget"
}

# Colores para páginas MAN
function man() {
    env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

# Previsualización con FZF
function fzf-lovely(){
	local preview_cmd='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -500'
	if [ "$1" = "h" ]; then
		fzf -m --reverse --preview-window down:20 --preview "$preview_cmd"
	else
		fzf -m --preview "$preview_cmd"
	fi
}

# Borrado seguro de archivos
function rmk(){
	if [[ -f "$1" ]]; then
		scrub -p dod "$1"
		shred -zun 10 -v "$1"
	else
		echo "[!] El archivo no existe"
	fi
}

# 7. Carga de Integraciones, Plugins y Tema
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Verificación de plugins antes de cargar
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]] && source /usr/share/zsh-sudo/sudo.plugin.zsh

# Tema Powerlevel10k
[[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Finalización de Powerlevel10k Instant Prompt (Debe ir al final)
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize
