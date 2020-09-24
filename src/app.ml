open Core_kernel

(******************************************************************************
 * model
 *****************************************************************************)
module Model = struct
  type t =
    { gigs : Gig.t list
    ; lang : Lang.t
    ; bio : string
    } [@@deriving sexp, compare]

  let create () =
    { gigs = []
    ; lang = Lang.default
    ; bio = ""
    }

  let cutoff t1 t2 = compare t1 t2 = 0
end

(******************************************************************************
 * action
 *****************************************************************************)
module Action = struct
  type t =
    | FetchGigs of unit
    | FetchBio of Lang.t
    | SetBio of string
    | SetGigs of string
  [@@deriving sexp]

  let apply (model : Model.t) action _ ~schedule_action =
    let fetch_gigs () =
      Gig.fetch ~handler:(fun gigs -> schedule_action (SetGigs gigs));
      model
    in
    let fetch_bio lang =
      if (String.is_empty model.bio) || (Lang.compare lang model.lang <> 0)
      then
        begin
          Bio.fetch ~lang ~handler:(fun bio -> schedule_action (SetBio bio));
          { model with lang }
        end
      else
        model
    in

    match action with
    | FetchGigs _ -> fetch_gigs ()
    | FetchBio lang -> fetch_bio lang
    | SetBio bio -> { model with bio }
    | SetGigs gigs -> { model with gigs = Gig.parse gigs }
end

(******************************************************************************
 * state
 *****************************************************************************)
module State = struct type t = unit end

(******************************************************************************
 * on_startup
 *****************************************************************************)
let on_startup ~(schedule_action : Action.t -> unit) _ =
  schedule_action (Action.FetchGigs ());
  schedule_action (Action.FetchBio Lang.default)
  |> Async_kernel.return

(******************************************************************************
 * view
 *****************************************************************************)
let view (model : Model.t) ~(inject : Action.t -> Incr_dom.Vdom.Event.t) =
  let title = "Freddie & the Cannonballs" in
  let open Incr_dom.Vdom in
  let make_img attrs src title =
    Node.create "img"
      (Attr.create "alt" title :: ((Attr.create "src" src) :: attrs))
      []
  in
  let make_media_icon title url =
    Node.a
      [ Attr.href url]
      [ make_img
          [ Attr.classes ["rounded";"ml-2";"mr-2"]
          ; Attr.create "width" "30"
          ]
          ("icons/" ^ (String.lowercase title) ^ ".png")
          title
      ]
  in
  let make_hidden_header text =
    Node.h3 [ Attr.class_ "d-none" ] [ Node.text text ]
  in
  let make_lang_button lang =
    Node.button
      [ Attr.classes ["btn";"btn-sm";"btn-outline-secondary";"mr-1"]
      ; Attr.type_ "button"
      ; Attr.on_click (fun _ -> Action.FetchBio lang |> inject)
      ]
      [ Lang.string_of_lang lang |> Node.text ]
  in
  let make_row lst =
    Node.div [ Attr.classes ["row";"mt-4"] ] lst
  in
  let logo =
    Node.header
      [ Attr.classes ["row";"mt-4"] ]
      [ Node.div
          [ Attr.classes ["col";"text-center"] ]
          [ make_img [ Attr.class_ "img-fluid" ] "img/logo.jpg" title ]
      ]
  in
  let icons =
    Node.div
      [ Attr.classes ["row";"mt-4"] ]
      [ Node.create "nav"
          [ Attr.classes ["col";"text-center"] ]
          [ make_media_icon "Facebook"  "https://facebook.com/FreddieCannonballs"
          ; make_media_icon "Instagram" "https://instagram.com/freddieandthecannonballs"
          ; make_media_icon "YouTube"   "https://www.youtube.com/channel/UCo2lWw8G9p1WiJUHsV8FeUA"
          ; make_media_icon "Email"     "mailto:info@freddieandthecannonballs.com"
          ]
      ]
  in
  let photo =
    Node.section
      [ Attr.classes ["col-md";"mt-3"] ]
      [ make_hidden_header "Band picture"
      ; make_img
          [ Attr.classes ["img-fluid";"img-thumbnail"] ]
          "img/band.jpg" title
      ]
  in
  let bio =
    Node.section
      [ Attr.classes ["col-md";"mt-3"] ]
      [ make_hidden_header "Biography"
      ; Node.p
          [ Attr.class_ "text-justify" ]
          [ Parse.node_of_string model.bio ]
      ; Node.div
          []
          (List.map Lang.all ~f:make_lang_button)
      ]
  in
  let gigs =
    let gigs_list =
      let future_gig g =
        Date.((Gig.date g) >= today ~zone:Time.Zone.utc)
      in
      let format_gig g =
        let pretty_date d =
          (d |> Date.day |> string_of_int) ^ " " ^
          (d |> Date.month |> Month.to_string) ^ " " ^
          (d |> Date.year |> string_of_int)
        in
        (Gig.date g |> pretty_date, Gig.desc g)
      in
      match List.filter model.gigs ~f:future_gig with
      | [] -> ["", Gig.no_events_msg]
      | xs -> List.map xs ~f:format_gig
    in
    let make_gig_tr (date, desc) =
      Node.tr
        []
        [ Node.td
            [ Attr.classes ["text-nowrap";"text-right"] ]
            [ Node.text date ]
        ; Node.td
            []
            [ Node.text desc ]
        ]
    in
    Node.section
      [ Attr.classes ["col";"offset-lg-2";"col-lg-8";"centered"] ]
      [ Node.h3 [] [ Node.text "Events" ]
      ; Node.table
          [ Attr.classes ["table";"table-hover"] ]
          [ Node.tbody [] (List.map gigs_list ~f:make_gig_tr) ]
      ]
  in
  let colophon =
    Node.p
      [ Attr.classes ["text-center";"text-muted"]
      ; Attr.style (`Rem 0.6 |> Css_gen.font_size)
      ]
      [ Node.hr []
      ; Node.text "Copyright © 2019 Freddie & The Cannonballs"
      ; Node.text " / Social media icons designed by "
      ; Node.a
          [ Attr.href "https://www.alfredocreates.com" ]
          [ Node.text "AlfredoCreates.com" ]
      ; Node.text " / Site generated with "
      ; Node.a
          [ Attr.href "https://github.com/janestreet/incr_dom" ]
          [ Node.text "Incr_dom" ]
      ]
  in
  Node.div
    [ ]
    [ Node.div
        [ Attr.class_ "container" ]
        [ logo ; icons ; (make_row [ photo ; bio ]) ; (make_row [ gigs ]) ]
    ; Node.footer
        [ Attr.class_ "container" ]
        [ colophon ]
    ]

(******************************************************************************
 * create
 *****************************************************************************)
let create model ~old_model:_ ~inject =
  let open Incr_dom in
  let open Incr.Let_syntax in
  let%map model = model in
  let apply_action = Action.apply model in
  let view = view model ~inject in
  Incr_dom.Component.create ~apply_action model view
