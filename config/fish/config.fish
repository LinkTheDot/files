export LSCOLORS=ExFxCxDxBxegedabagacad
export CLICOLOR="YES"
export DOTFILES=$HOME/.dotfiles
export EDITOR="nvim"
export STARSHIP_LOG=error
export XDG_CONFIG_HOME=$HOME/.config
export RUBY_YJIT_ENABLE=1
export LOCAL_POSTGRES_DB_PASSWORD="Ocarinaofshit10!"

for f in $HOME/.config/fish/aliases/*fish
  source $f
end

if test -e ~/.localrc.fish
  source ~/.localrc.fish
end

# machine-local env vars (gitignored)
if test -e $HOME/.config/fish/local.fish
  source $HOME/.config/fish/local.fish
end

if status is-interactive && command -v starship >/dev/null 2>&1
  # stop visual bell from doing anything
  printf "\e[?1042l"

  starship init fish | source
  direnv hook fish | source

  # fish 4.x changed cancel-commandline to not move to a new line; restore old behavior
  bind \cc 'commandline -f end-of-line; printf "^C\n"; commandline --replace ""; commandline -f execute'

  # don't exit shell (and close the tmux pane) on ctrl-d at an empty prompt
  bind \cd 'commandline -f delete-char'
end

# if string match -q "*not*" (service docker status)
#     sudo /usr/sbin/service docker start
# end

# Mine
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DATABASE_PASSWORD="Ocarinaofshit10!"
export PGPASSWORD="Ocarinaofshit10!"
export WORKDIR="/mnt/c/Users/Cirno/OneDrive/Desktop/1a-for-working-on-shit"

set -gx HOMELAB_ADDRESS (ssh -G homelab | awk '$1 == "hostname" { print $2 }')
# Disable annoying keyring popup
set -x PKG_CONFIG_PATH $HOME/.nix-profile/lib/pkgconfig $PKG_CONFIG_PATH

# botan@2 is keg-only in Homebrew; botan-sys finds it via pkg-config,
# and the linker needs LIBRARY_PATH to locate libbotan-2.dylib at link time.
if test -d /opt/homebrew/opt/botan@2/lib
    set -gx PKG_CONFIG_PATH /opt/homebrew/opt/botan@2/lib/pkgconfig $PKG_CONFIG_PATH
    set -gx LIBRARY_PATH /opt/homebrew/opt/botan@2/lib $LIBRARY_PATH
end
set -x PYTHON_KEYRING_BACKEND keyring.backends.null.Keyring

# ^Mine^
