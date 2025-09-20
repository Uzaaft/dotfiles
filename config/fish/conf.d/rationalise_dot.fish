# Expand ... to ../.. recursively
function __rationalise_dot
    set -l cmd (commandline -b)
    set -l cursor (commandline -C)

    # Get the part before cursor
    set -l before (string sub -l $cursor -- "$cmd")

    # Check if we're typing dots after path separator or at start
    if string match -qr '(^|/| |\t|\n|\||;|&)\.{2}$' -- "$before"
        commandline -i /..
    else
        commandline -i .
    end
end

# Bind . to the rationalise function
bind . __rationalise_dot
bind -M insert . __rationalise_dot