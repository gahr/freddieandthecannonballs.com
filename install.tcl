#!/usr/bin/env tclsh

set assets { index.stcl favicons icons img funcs.tcl scripts.js }

set srcdir [file dirname [info script]]
set dstdir [lindex $::argv 0]
if {$dstdir eq {}} {
    puts stderr "Usage: $::argv0 dest"
    exit 1
}

file mkdir $dstdir

proc install {src dst} {
    if {![file isdirectory $src] || ![file exists $dst]} {
        puts "$src -> $dst"
        file copy -force $src $dst
    } else {
        foreach child [glob -nocomplain -directory $src *] {
            install $child [file join $dst [file tail $child]]
        }
    }
}

foreach asset $assets {
    install [file join $srcdir $asset] [file join $dstdir [file tail $asset]]
}
