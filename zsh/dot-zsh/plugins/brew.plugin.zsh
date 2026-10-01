brew() {
  case "$1" in
    outdated)
      if [[ $# -eq 1 ]]; then
        print -c $(command brew outdated | cut -f1 -d" ")
      else
        command brew "$@"
      fi
      ;;
    requested)
      print -P "%F{blue}==>%f %BFormulae%b"
      print -c $(command brew list --installed-on-request)
      print -P "\n%F{blue}==>%f %BCasks%b"
      print -c $(command brew list --cask)
      ;;
    uses)
      shift
      command brew uses --installed --recursive "$@"
      ;;
    *)
      command brew "$@"
      ;;
  esac
}
