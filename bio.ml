let bio_of_lang lang =
  let open Incr_dom.Tyxml in
  let bio = match lang with
    | Lang.Eng -> [%html {|<p><b>Freddie “Cannonball” Albertoni</b> is a Swiss
        bass player who has been on the Swiss-Italian blues scene for 15 years.
        He was the founder of a renowned local blues/rock band called ‘The
        Flag’ and for many years a bass player for legendary Swiss bluesman
        <b>Bat Battiston</b>. In autumn 2018, Federico Albertoni decides to
        take the frontman role, to start singing and to form his own 100% blues
        band: <b>Freddie & The Cannonballs</b>. The experienced and talented
        musicians who joined his sextet are his musical brother <b>Mad
        Mantello</b> (guitar), drummer <b>Roberto Panzeri</b>, <b>Cristiano
        Arcioni</b> (organ) and saxophone players <b>Nigel Casey</b> and
        <b>Olmo Antezana</b>.  Having a small horn section allows Freddie’s
        band to have the swinging sound of the blues of the 50s and to combine
        it with modern sounds too. The band’s repertoire features many original
        songs as well as a substantial tribute to Jimmie Vaughan. The band’s
        first record, i.e. an EP entitled “F” which features four original
        songs, came out in June 2019. Freddie & the Cannonballs then had the
        chance to perform at two major Swiss blues festivals: <b>Bellinzona
        Blues</b> and <b>Lugano Blues to Bop</b>. In May 2020 the band has the
        great honour of being selected as one of the four finalists of the
        <b>2020 Swiss Blues Challenge</b>, which was later postponed to July
        2nd 2021 due to the unfortunate Covid-19 situation.</p>|}]

    | Lang.Ita -> [%html {|<p><b>Freddie “Cannonball” Albertoni</b> è un
        bassista attivo da 15 anni sulla scena blues/rock ticinese. Per diversi
        anni è stato impegnato musicalmente con la formazione rock-blues ‘The
        Flag’ e per quasi un decennio ha accompagnato al basso il leggendario
        bluesman svizzero <b>Bat Battiston</b>.  Dopo queste e altre esperienze
        in generi affini al blues, Federico Albertoni decide, nell’autunno del
        2018, di assumere il ruolo di frontman, di cantare e di fondare la sua
        band blues al 100%: <b>Freddie & The Cannonballs</b>. I talentuosi
        musicisti che compongono questo sestetto sono il compagno di avventure
        musicali <b>Mad Mantello</b> alla chitarra, il batterista <b>Roberto
        Panzeri</b>, <b>Cristiano Arcioni</b> all’organo e, infine, i
        sassofonisti <b>Nigel Casey</b> e <b>Olmo Antezana</b>. La sezione
        fiati permette all’ensemble di proporre quelle sonorità ispirate al
        blues degli anni ’50, senza però tralasciare un certo tocco di
        modernità. Il repertorio di Freddie & The Cannonballs è costituito
        anche da diversi brani di propria composizione e da un sostanzioso
        omaggio a Jimmie Vaughan. Il primo lavoro discografico, un EP
        intitolato “F” contenente quattro brani originali, è uscito a giugno
        2019.  Durante l’estate 2019 Freddie & the Cannonballs partecipano a
        due prestigiosi blues festival elvetici: <b>Bellinzona Blues</b> e
        <b>Lugano Blues to Bop</b>. A maggio 2020 la band ha il grande onore di
        essere selezionata per la finale dello <b>Swiss Blues Challenge
        2020</b> che, a causa della  situazione legata al Covid-19, viene
        posticipata al 2 luglio 2021.</p>|}]
  in Html.toelt bio
