package require json::write

namespace eval util {
  proc with {fname mode varname script} {
    upvar $varname fd
    if {![catch {open $fname $mode} fd]} {
      try {
        uplevel $script
      } finally {
        close $fd
      }
    }
  }
}

namespace eval markup {
  proc transform {text} {
    string map {
      \{ <b>
      \} </b>
      <  <i>
      >  </i>
    } $text
  }
}

namespace eval bio {
  proc generate {lang} {
    util::with "./data/bio-$lang.txt" r fd {
      markup::transform [read $fd]
    }
  }
}

namespace eval lang {
  variable langs [dict create en English it Italiano]
  variable terms [dict create \
    events   [list {Events}  \
                   {Eventi}] \
    download [list {Download the full album (CD1)} \
                   {Scarica l'intero album (CD1)}] \
    here     [list {here} \
                   {qui}] \
    bio      [list [bio::generate en]  \
                   [bio::generate it]] \
  ]

  proc make-buttons {} {
    variable langs

    foreach {short long} $langs {
      @ "<button class='btn btn-sm btn-outline-secondary mr-1' type='button' id='lang-$short'>$long</button>"
    }
  }

  proc langs {} {
    variable langs
    dict keys $langs
  }

  proc terms {} {
    variable terms
    dict keys $terms
  }
 
  proc translate {term} {
    variable terms
    set idx [lsearch -exact [langs] $::g(lang)]
    if {$idx == -1} {
      set idx 0
    }
    set elem [dict getdef $terms $term {}]
    if {$elem eq {}} {
      return $term
    }
    lindex $elem $idx
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


namespace eval i18n {
  proc generate {} {
    foreach t [lang::terms] {
      lappend elems $t [json::write string [lang::translate $t]]
    }
    json::write object {*}$elems
  }
}

namespace eval gigs {
  variable data_file {./data/gigs.txt} \
           in_format  {%Y-%m-%d} \
           out_format {%e %b %Y}

  variable classes {text-nowrap text-right}

  proc approx-day {epoch} {
    expr {int(floor($epoch/86400)) * 86400}
  }

  proc parse-one {line} {
    variable in_format

    # We accept single dates and periods
    # 2020-05-11 Title
    # 2020-05-11,2020-05-14 Title
    set rex {^(\d{4}-\d{2}-\d{2})(?:,(\d{4}-\d{2}-\d{2}))? (.*)$}
    if {![regexp $rex $line _ start end desc]} {
      return {}
    }
    if {[catch {clock scan $start -format $in_format} startepoch]} {
      return {}
    }
    if {$end ne {}} {
      if {[catch {clock scan $end -format $in_format} endepoch]} {
        return {}
      }
    } else {
      set endepoch 0
    }

   list $startepoch $endepoch [markup::transform $desc]
  }

  proc gigs {} { 
    variable data_file

    set gigs [list]
    util::with $data_file r fd {
      while {[gets $fd line] >= 0} {
        set gig [parse-one $line]
        if {[llength $gig] == 3} {
          lappend gigs $gig
        }
      }
    }
    lsort -index {0} $gigs
  }

  proc generate-one {date desc} {
    variable classes
    namespace path ::scgi::html
    tr {} [list [td [list class $classes] [list $date]] [td {} [list $desc]]]
  }

  proc generate {} {
    variable out_format

    set today [approx-day [clock seconds]]

    set out ""
    foreach gig [gigs] {
      lassign $gig startepoch endepoch desc
      if {[approx-day $startepoch] >= $today} {
        set date [clock format $startepoch -format $out_format]
        if {$endepoch != 0} {
          set edate [clock format $endepoch -format $out_format]
          lassign [split $date { }] sd sm sy
          lassign [split $edate { }] ed em ey
          if {$sm eq $em && $sy eq $ey} {
            set date "$sd - $ed $sm $sy"
          } else {
            append date " - " $edate
          }
        }
        append out [generate-one $date $desc]
      }
    }
    set out
  }
}

namespace eval icons {
  variable icons {
    facebook  https://facebook.com/FreddieCannonballs
    instagram https://instagram.com/freddieandthecannonballs
    youtube   https://www.youtube.com/channel/UCo2lWw8G9p1WiJUHsV8FeUA
    spotify   https://freddieandthecannonballs.hearnow.com
    email     mailto:info@freddieandthecannonballs.com
  }

  variable classes {rounded ml-1 mr-1 icon}

  proc attrs {name} {
    variable classes
    lappend out class $classes
    lappend out src   icons/$name.png
    lappend out alt   [string totitle $name]
    set out
  }

  proc generate {} {
    variable icons
    namespace path ::scgi::html
    dict for {name uri} $icons {
      @ [a [list href $uri] [list [img [attrs $name] {}]] ]
    }
  }
}

namespace eval action {
  proc handle {} {
    switch [dict getdef $::scgi::params action {}] {
      {get-i18n} {
        @ [i18n::generate]
      }
      {default} {
        return
      }
    }
    exit
  }
}

namespace eval site {
  proc make-songs {} {
    set songs {
      {Cannonballs!}
      {The Proof Is In The Pudding}
      {Let Me Sleep}
      {yOur Pain}
      {Barking Up The Wrong Tree}
      {Mosquito}
      {Unsung Hero}
      {Banana}
      {We Shall Not Be Moved}}
  
    @ <ol>
    set l [llength $songs]
    set i 1
    foreach song $songs {
      set src [string map {{ } %20} "$i. $song.mp3"]
      @ <li>
      @ "<button class='btn btn-sm mr-1' type='button' id='song-btn-$i' onclick='play($i, $l)'>&#x23EF;</button>"
      @ "<span id='song-title-$i'>$song</span>"
      @ " <audio id='song-$i'><source src='data/TwoSidesOfTheSameCoin/$src' type='audio/mpeg'></audio>"
      @ </li>
      incr i
    }
    @ </ol>
    @ "<p><span id='i18n-download'></span> "
    @ "<a href='data/TwoSidesOfTheSameCoin/FreddieAndTheCannonballs-TwoSidesOfTheSameCoin.zip'><span id='i18n-here'></span></a>."
    @ "</p>"
  }

  proc download-page {} {

    @ {
      <!-- Cover + download -->
      <div class="row mt-3">

        <!-- Cover --> 
        <section class="col-md mt-3">
          <h3 class="d-none">Album cover</h3>
          <img class="img-fluid img-thumbnail"
               src="img/twosides.png"
               alt="Two sides of the same coin"/>
        </section>

        <!-- Download -->
        <section class="col-md mt-3">
          <h3 class="d-none">Downloads</h3>}; make-songs; @ {
        </section>

      </div>
    }
  }

  proc def-page {} {
    @ {
      <!-- Picture + Bio -->
      <div class="row mt-3">

        <!-- Freddie picture -->
        <section class="col-md">
          <h3 class="d-none">Freddie picture</h3>
          <p class="text-justify">
            <img class="img-fluid img-thumbnail"
                 src="img/freddie-2022.jpg"
                 alt="Freddie & the Cannonballs"/>
          </p>
        </section>

        <!-- Band picture -->
        <section class="col-md">
          <h3 class="d-none">Band picture</h3>
          <img class="img-fluid img-thumbnail"
               src="img/band-2022.jpg"
               alt="Freddie & the Cannonballs"/>
        </section>

      </div>

      <div class="row">
        <section class="col-md mt-2">
          <h3 class="d-none">Biography</h3>
          <p class="text-justify" id="i18n-bio"></p>
        </section>

      </div>

      <!-- Gigs -->
      <div class="row mt-4">

        <section class="col offset-lg-2 col-lg-8 centered">
          <h3 class="d-none">Events</h3>
          <span id="i18n-events" class="h3"></span>
          <table class="table table-hover">
            <tbody>}; @ [gigs::generate]; @ {
            </tbody>
          </table>
        </section>

      </div>
    }
  }

  proc render {} {
    switch [dict getdef $::scgi::params page {}] {
      {33829ea9-e4cc-11ec-a758-001a4a7ec6be} {
        download-page
      }
      default {
        def-page
      }
    }
  }
}

set g(lang) [lang::pick]

# vim: set ft=tcl ts=2 sw=2 expandtab:
