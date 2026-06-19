brew() {
  case "$1" in
    uses)
      shift
      command brew uses --installed --recursive "$@"
      ;;
    outdated)
      if [[ $# -eq 1 ]]; then
        print -c $(command brew outdated | cut -f1 -d" ")
      else
        command brew "$@"
      fi
      ;;
    *)
      command brew "$@"
      ;;
  esac
}
