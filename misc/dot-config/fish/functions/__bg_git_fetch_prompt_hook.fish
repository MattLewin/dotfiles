function __bg_git_fetch_prompt_hook --on-variable PWD
    status --is-interactive; or return

    set -q BG_GIT_FETCH_PERIOD; or set -g BG_GIT_FETCH_PERIOD 300

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        # Start a single background timer loop per shell session.
        if set -q __bg_git_fetch_timer_pid
            if command kill -0 $__bg_git_fetch_timer_pid >/dev/null 2>&1
                return
            end
            set -e __bg_git_fetch_timer_pid
        end

        begin
            while true
                bg_git_fetch
                sleep $BG_GIT_FETCH_PERIOD
            end
        end &
        set -g __bg_git_fetch_timer_pid $last_pid
        disown $__bg_git_fetch_timer_pid 2>/dev/null
    else
        # Stop the timer when outside a repo.
        if set -q __bg_git_fetch_timer_pid
            command kill $__bg_git_fetch_timer_pid >/dev/null 2>&1
            set -e __bg_git_fetch_timer_pid
        end
    end
end

function __bg_git_fetch_prompt_hook_init --on-event fish_prompt
    # Kick the PWD handler once on startup so a repo in the initial dir starts the timer.
    __bg_git_fetch_prompt_hook
    functions -e __bg_git_fetch_prompt_hook_init
end
