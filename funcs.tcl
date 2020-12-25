set langs {en it}
set in_format {%Y-%m-%d}
set out_format {%e %b %Y}

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

set today [approx-day [clock seconds]]

proc get-bio {lang} {
    with "./data/bio-$lang.txt" r fd {
        string map { \{ <b> \} </b> } [read $fd]
    }
}

proc pick-bio-lang {} {
    set lang [::scgi::param lang]
    if {$lang in $::langs} {
        set lang
    } else {
        lindex $::langs 0
    }
}

proc get-gigs {} {
    set gigs [list]
    with {./data/gigs.txt} r fd {
        while {[gets $fd line] >= 0} {
            set date [string range $line 0 10]
            set desc [string range $line 11 end]
            if {$date eq {} || $desc eq {}} {
                continue
            }
            if {[catch {clock scan $date -format $::in_format} epoch]} {
                continue
            }
            lappend gigs [list $epoch $desc]
        }
    }
    set gigs
}

proc format-gig {date desc} {
    return "\
        <tr>\
            <td class='text-nowrap text-right'>$date</td>\
            <td>$desc</td>\
        </tr>"
}

proc format-gigs {gigs} {
    set out ""
    foreach gig $gigs {
        lassign $gig epoch desc
        if {[approx-day $epoch] >= $::today} {
            set date [clock format $epoch -format $::out_format]
            append out [format-gig $date $desc]
        }
    }
    set out
}

# vim: set ft=tcl ts=4 sw=4 expandtab:
