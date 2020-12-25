namespace eval util {
    proc with {fname mode varname script} {
        try {
            upvar $varname fd
            set fd [open $fname $mode]
            uplevel $script
        } finally {
            close $fd
        }
    }
}

namespace eval lang {
    variable terms {
        en {}
        it {
            events eventi
        }
    }

    proc langs {} {
        variable terms
        dict keys $terms
    }

    proc translate {term} {
        variable terms
        dict getdef [dict get $terms $::g(lang)] $term $term
    }

    proc get-param {} {
        set lang [dict getdef $::scgi::params lang {}]
        if {$lang in [langs]} {
            set lang
        } else {
            return {}
        }
    }

    proc get-accept-language {} {
        set candidates [list]

        set accept [dict getdef $::scgi::headers HTTP_ACCEPT_LANGUAGE {}]
        if {$accept ni {{} *}} {
            set langs [langs]
            foreach lang [split $accept {,}] {
                lassign [split $lang {-}] tag
                lassign [split $tag {;}] tag quality
                if {[string tolower $tag] in $langs} {
                    if {$quality eq {}} {
                        set quality 1.0
                    } else {
                        set quality [string range $quality 3 end]
                        if {![string is double $quality]} {
                            set quality 1.0
                        }
                    }
                    lappend candidates [list $quality $tag]
                }
            }
        }
        lindex [lsort -decreasing -real -index 0 $candidates] 0 1
    }

    proc pick {} {
        set lang [get-param]
        if {$lang eq {}} {
            set lang [get-accept-language]
        }
        if {$lang ne {}} {
            set lang
        } else {
            lindex [langs] 0
        }
    }
}

namespace eval bio {
    proc generate {} {
        util::with "./data/bio-$::g(lang).txt" r fd {
            string map { \{ <b> \} </b> } [read $fd]
        }
    }
}

namespace eval gigs {
    variable in_format  {%Y-%m-%d} \
             out_format {%e %b %Y}

    proc approx-day {epoch} {
        expr {int(floor($epoch/86400)) * 86400}
    }

    proc gigs {} { 
        variable in_format

        set gigs [list]
        util::with {./data/gigs.txt} r fd {
            while {[gets $fd line] >= 0} {
                set date [string range $line 0 10]
                set desc [string range $line 11 end]
                if {$date eq {} || $desc eq {}} {
                    continue
                }
                if {[catch {clock scan $date -format $in_format} epoch]} {
                    continue
                }
                lappend gigs [list $epoch $desc]
            }
        }
        set gigs
    }

    proc generate-one {date desc} {
        return "\
            <tr>\
                <td class='text-nowrap text-right'>$date</td>\
                <td>$desc</td>\
            </tr>"
    }

    proc generate {} {
        variable out_format

        set today [approx-day [clock seconds]]

        set out ""
        foreach gig [gigs] {
            lassign $gig epoch desc
            if {[approx-day $epoch] >= $today} {
                set date [clock format $epoch -format $out_format]
                append out [generate-one $date $desc]
            }
        }
        set out
    }
}

namespace eval action {
    proc handle {} {
        switch [dict getdef $::scgi::params action {}] {
            {get-bio} {
                @ [bio::generate]
            }
            {default} {
                return
            }
        }
        exit
    }
}

set g(lang) [lang::pick]

# vim: set ft=tcl ts=4 sw=4 expandtab:
