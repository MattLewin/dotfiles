set -l os (uname -s | tr '[:upper:]' '[:lower:]')
set -l os_dir (status dirname)/os.d

if test -r "$os_dir/$os.fish"
    source "$os_dir/$os.fish"
end
