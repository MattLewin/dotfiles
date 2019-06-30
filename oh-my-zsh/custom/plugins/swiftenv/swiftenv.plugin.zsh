() {
    if type swiftenv >/dev/null; then
        eval "$(swiftenv init -)"
    else
        cat <<EOF >&2
        --- SWIFTENV ---
        Unable to location swiftenv binary
        ----------------
EOF
        return 1
    fi
}
