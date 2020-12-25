proc with {fname mode varname script} {
    try {
        upvar $varname fd
        set fd [open $fname $mode]
        uplevel $script
    } finally {
        close $fd
    }
}

proc approx-day {epoch} {
    expr {int(floor($epoch/86400)) * 86400}
}

# vim: set ft=tcl ts=4 sw=4 expandtab:
