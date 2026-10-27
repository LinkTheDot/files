if status is-interactive
  if not command -s mise > /dev/null
    echo "mise: command not found. Install mise to manage language versions"
  else
    # mise activate manages PATH itself; it doesn't require the shims dir
    # to exist ahead of time (that dir is only created after the first
    # `mise install`), so this must not be gated on it.
    mise activate fish | source

    set -l mise_shims_dir "$HOME/.local/share/mise/shims"

    if test -d $mise_shims_dir
      fish_add_path -m $mise_shims_dir
    end
  end
end
