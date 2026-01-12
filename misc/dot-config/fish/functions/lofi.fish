function lofi --description 'Apply dialogue effects (radio/walkie-talkie) to audio'
    set -l do_radio false
    set -l do_wt false
    set -l input ""

    # Fish-style argument parsing
    for arg in $argv
        switch $arg
            case '-radio'
                set do_radio true
            case '-wt'
                set do_wt true
            case '*'
                set input $arg
        end
    end

    # Check for empty input or no flags
    if test "$do_radio" = false -a "$do_wt" = false; or test -z "$input"
        echo "Usage: lofi [-radio] [-wt] <file>"
        return 1
    end

    # File path manipulation
    set -l base (string replace -r '\.[^.]*$' '' $input)
    set -l ext (string replace -r '^.*\.' '' $input)
    
    # Audio filter strings
    set -l norm "loudnorm=I=-16:TP=-1.5:LRA=11"
    set -l comp "compand=0.3|0.3:6|6:-70/-60|-20/-14"
    set -l peak_cap "alimiter=limit=0.316:level=0"

    if test "$do_radio" = true
        ffmpeg -hide_banner -loglevel error -stats -i "$input" -af \
        "$norm,$comp,firequalizer=gain='if(between(f,400,3500),0,-60)+if(between(f,1000,2000),6,0)',aresample=48000,$peak_cap" \
        -c:a pcm_s24le "$base-radio.$ext"
    end

    if test "$do_wt" = true
        ffmpeg -hide_banner -loglevel error -stats -i "$input" -af \
        "$norm,$comp,firequalizer=gain='if(between(f,600,2500),0,-70)',aresample=48000,$peak_cap" \
        -c:a pcm_s24le "$base-wt.$ext"
    end
end
