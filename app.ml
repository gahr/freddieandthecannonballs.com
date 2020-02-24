open Core_kernel

(* model *)
module Model = struct
  type t =
    { gigs : Gig.t list
    ; lang : Lang.t
    } [@@deriving sexp, compare]

  let create () =
    { gigs = []
    ; lang = Lang.default
    }

  let cutoff t1 t2 = compare t1 t2 = 0
end

(* action *)
module Action = struct
  type t =
  | SetBioLanguage of Lang.t
  | SetGigsContent of string
  [@@deriving sexp]

  let apply (model : Model.t) action _ ~schedule_action:_ =
    match (action : t) with
    | SetBioLanguage lang -> { model with lang }
    | SetGigsContent gigs -> { model with gigs = Gig.parse gigs }
end

(* state *)
module State = struct
  type t = unit
end

(* on_startup *)
let on_startup ~(schedule_action : Action.t -> unit) _ =
  let open Js_of_ocaml_lwt in

  let load_gigs =
    let%lwt resp = XmlHttpRequest.get Gig.fetch_url in
    schedule_action @@ Action.SetGigsContent resp.content;
    Lwt.return ()
  in

  (* Start asynchronous jobs *)
  let () =
    Lwt.async (fun () ->
      let%lwt () = load_gigs in
      Lwt.return ()
    )
  in
  Async_kernel.Deferred.unit

(* view *)
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
      ; Attr.on_click (fun _ -> Action.SetBioLanguage lang |> inject)
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
          [ Bio.bio_of_lang model.lang ]
      ; Node.div
          []
          (List.map Lang.all make_lang_button)
      ]
  in
  let gigs =
    let make_gig_tr g =
      let pretty_date d =
          (d |> Date.day |> string_of_int) ^ " " ^
          (d |> Date.month |> Month.to_string) ^ " " ^
          (d |> Date.year |> string_of_int)
      in
      Node.tr
        []
        [ Node.td
            [ Attr.classes ["text-nowrap";"text-right"] ]
            [ Gig.date g |> pretty_date |> Node.text ]
        ; Node.td
            []
            [ Gig.desc g |> Node.text ]
        ]
    in
    let make_future_gig g =
      match Date.((Gig.date g) >= today Time.Zone.utc) with
      | true  -> Some (make_gig_tr g)
      | false -> None
    in
    Node.section
      [ Attr.classes ["col";"offset-lg-2";"col-lg-8";"centered"] ]
      [ Node.h3 [] [ Node.text "Events" ]
      ; Node.table
          [ Attr.classes ["table";"table-hover"] ]
          [ Node.tbody [] (List.filter_map model.gigs make_future_gig) ]
      ]
  in
  let colophon =
    Node.p
        [ Attr.classes ["text-center";"text-muted"]
        ; Attr.style (Css_gen.font_size (Css_gen.Length.(`Rem 0.6)))
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

(* create *)
let create model ~old_model:_ ~inject =
  let open Incr_dom in
  let open Incr.Let_syntax in
  let%map model = model in
  let apply_action = Action.apply model in
  let view = view model ~inject in
  Incr_dom.Component.create ~apply_action model view
