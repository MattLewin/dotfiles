# Route pip/pipx to uv/uvx (interactive shells only)
# Fish version: shims + completions cache + version-stamp refresh.

status is-interactive; or exit

# If uv isn't installed, do nothing.
type -q uv; or exit

# --- uv/uvx completions ---
set -l uv_completion_dir (set -q XDG_CACHE_HOME; and echo "$XDG_CACHE_HOME"; or echo "$HOME/.cache")/fish/completions
mkdir -p "$uv_completion_dir"

# Generate completion files if missing OR if uv/uvx changed (version-stamped).
set -l uv_stamp "$uv_completion_dir/.uv-completion-version"
set -l uvx_stamp "$uv_completion_dir/.uvx-completion-version"

set -l uv_ver (uv --version 2>/dev/null)
set -l uv_cached ""
test -f "$uv_stamp"; and set uv_cached (cat "$uv_stamp")

if not test -f "$uv_completion_dir/uv.fish"; or test "$uv_ver" != "$uv_cached"
    uv generate-shell-completion fish > "$uv_completion_dir/uv.fish" 2>/dev/null
    printf "%s\n" "$uv_ver" > "$uv_stamp" 2>/dev/null
end

if type -q uvx
    set -l uvx_ver (uvx --version 2>/dev/null)
    set -l uvx_cached ""
    test -f "$uvx_stamp"; and set uvx_cached (cat "$uvx_stamp")

    if not test -f "$uv_completion_dir/uvx.fish"; or test "$uvx_ver" != "$uvx_cached"
        uvx --generate-shell-completion fish > "$uv_completion_dir/uvx.fish" 2>/dev/null
        printf "%s\n" "$uvx_ver" > "$uvx_stamp" 2>/dev/null
    end
end

# Make fish load the generated completions.
if not contains -- "$uv_completion_dir" $fish_complete_path
    set -Ua fish_complete_path "$uv_completion_dir"
end

# --- shims ---
function __uv_pip_shim_version
    set -l uv_ver (uv --version 2>/dev/null)
    echo "pip (shim) -> uv pip | $uv_ver"
end

function pip --wraps=uv
    if test (count $argv) -ge 1
        switch $argv[1]
            case --version -V
                __uv_pip_shim_version
                return 0
        end
    end
    uv pip $argv
end

function pip3 --wraps=uv
    if test (count $argv) -ge 1
        switch $argv[1]
            case --version -V
                __uv_pip_shim_version
                return 0
        end
    end
    uv pip $argv
end

function __uv_pipx_shim_version
    set -l uv_ver (uv --version 2>/dev/null)
    set -l uvx_ver (uvx --version 2>/dev/null)
    echo "pipx (shim) -> uv tool / uvx | $uv_ver | $uvx_ver"
end

function pipx --wraps=uv
    if test (count $argv) -ge 1
        switch $argv[1]
            case --version -V
                __uv_pipx_shim_version
                return 0
            case run
                uvx $argv[2..-1]
                return $status
        end
    end
    uv tool $argv
end
