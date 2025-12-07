function bg_git_fetch --description "Idle-ish background git fetch, throttled per repo"
    set -q BG_GIT_FETCH_PERIOD; or set -g BG_GIT_FETCH_PERIOD 300

    # Must be in a git worktree (fast)
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    # Repo key (top-level path). If this fails, bail.
    set -l top (command git rev-parse --show-toplevel 2>/dev/null); or return

    # Turn repo path into a safe filename
    set -l key (string replace -ar '[^A-Za-z0-9._-]' '_' -- $top)
    set -l state_dir "$XDG_STATE_HOME/bg-git-fetch"
    if test -z "$XDG_STATE_HOME"
        set state_dir "$HOME/.local/state/bg-git-fetch"
    end
    mkdir -p $state_dir

    set -l stamp "$state_dir/$key.stamp"
    set -l now (date +%s)

    set -l last 0
    if test -f $stamp
        set last (cat $stamp 2>/dev/null)
    end

    # Throttle
    if test (math "$now - $last") -lt $BG_GIT_FETCH_PERIOD
        return
    end

    # Must have a remote
    command git remote >/dev/null 2>&1; or return

    # Update stamp before fetch to avoid refiring if fetch is slow
    echo $now > $stamp

    # Quiet, non-blocking fetch (uses your ssh-agent)
    env GIT_TERMINAL_PROMPT=0 \
        GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=5" \
        command git fetch --quiet --prune >/dev/null 2>&1
end
