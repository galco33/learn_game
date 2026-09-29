extends Node2D

const Etat = preload("res://scripts/game_state.gd")
const ARRIERE_PLAN = preload("res://DESIGN/carte-plate-etendue-ressources-aleatoires-reference.png")
const SPRITE_OUVRIER = preload("res://DESIGN/ouvrier-sprite-marche-4-directions-reference.png")
const SPRITE_CONIFERE = preload("res://DESIGN/arbre-conifere-ressource-bois.png")
const ANIMATION_CONIFERE_COUPE = preload("res://DESIGN/arbre-conifere-animation-coupe-reference.png")
const TUILES_ROUTE = preload("res://DESIGN/routes-autotiles-raccordements-reference.png")
const ICONE_BATIMENTS = preload("res://DESIGN/icone-batiments.png")
const ICONE_HABITATIONS = preload("res://DESIGN/icone-habitants.png")
const ICONE_RECOLTE = preload("res://DESIGN/icone-batiments-recolte.png")
const ICONE_ROUTES = preload("res://DESIGN/icone-routes.png")
const TAILLE_CASE := 48
const ORIGINE := Vector2(448, 48)

var jeu: EtatJeu
var mode := ""
var habitant_selectionne := -1
var message := "Assignez les 2 habitants à des arbres pour commencer."
var libelle_message: Label
var libelle_ressources: Label
var boutons_habitants: HBoxContainer
var boutons_construction: HBoxContainer
var categorie_active := "batiments"
var temps_animation := 0.0

func _ready() -> void:
	jeu = Etat.new()
	jeu.etat_modifie.connect(_actualiser)
	_creer_interface()
	_actualiser()
	queue_redraw()

func _process(delta: float) -> void:
	temps_animation += delta
	jeu.produire(delta)
	queue_redraw()

func _unhandled_input(evenement: InputEvent) -> void:
	if evenement.is_action_pressed("annuler"):
		mode = ""
		habitant_selectionne = -1
		message = "Action annulée."
		_actualiser()
		return
	if evenement is InputEventMouseButton and evenement.button_index == MOUSE_BUTTON_LEFT and evenement.pressed:
		var case_ := _case_depuis_position(evenement.position)
		if jeu.est_dans_grille(case_):
			_interagir_case(case_)

func _interagir_case(case_: Vector2i) -> void:
	if habitant_selectionne >= 0:
		message = jeu.assigner(habitant_selectionne, case_)
		mode = ""
		habitant_selectionne = -1
	elif mode == "route":
		message = jeu.placer_route(case_)
	elif mode == "suppression_route":
		message = jeu.retirer_route(case_)
	elif not mode.is_empty():
		message = jeu.construire(mode, case_)
		if message.ends_with("construit."):
			mode = ""
	else:
		message = "Choisissez un habitant, une route ou un bâtiment."
	_actualiser()

func _case_depuis_position(position: Vector2) -> Vector2i:
	return Vector2i(floor((position.x - ORIGINE.x) / TAILLE_CASE), floor((position.y - ORIGINE.y) / TAILLE_CASE))

func _creer_interface() -> void:
	var calque := CanvasLayer.new()
	add_child(calque)
	var panneau := ColorRect.new()
	panneau.color = Color("10251e", 0.96)
	panneau.position = Vector2(0, 480)
	panneau.size = Vector2(1280, 240)
	calque.add_child(panneau)
	var marge := MarginContainer.new()
	marge.position = Vector2(22, 492)
	marge.size = Vector2(1236, 216)
	calque.add_child(marge)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 6)
	marge.add_child(colonne)
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation", 24)
	colonne.add_child(entete)
	var titre := Label.new()
	titre.text = "VILLE IDLE"
	titre.add_theme_font_size_override("font_size", 22)
	entete.add_child(titre)
	libelle_ressources = Label.new()
	libelle_ressources.add_theme_font_size_override("font_size", 18)
	entete.add_child(libelle_ressources)
	var legende := Label.new()
	legende.text = "A : arbre · R : rocher · S1/S2 : station · SCI : scierie · CAR : carrière · MAI : maison · ENT : entrepôt"
	legende.add_theme_color_override("font_color", Color("b8c7d9"))
	colonne.add_child(legende)
	var ligne_habitants := HBoxContainer.new()
	ligne_habitants.add_theme_constant_override("separation", 8)
	colonne.add_child(ligne_habitants)
	var titre_habitants := Label.new()
	titre_habitants.text = "HABITANTS"
	titre_habitants.custom_minimum_size = Vector2(100, 38)
	ligne_habitants.add_child(titre_habitants)
	boutons_habitants = HBoxContainer.new()
	boutons_habitants.add_theme_constant_override("separation", 8)
	ligne_habitants.add_child(boutons_habitants)
	var categories := HBoxContainer.new()
	categories.add_theme_constant_override("separation", 10)
	colonne.add_child(categories)
	_ajouter_categorie(categories, "BÂTIMENTS", "batiments")
	_ajouter_categorie(categories, "HABITATIONS", "habitations")
	_ajouter_categorie(categories, "BÂT. DE RÉCOLTE", "recolte")
	_ajouter_categorie(categories, "ROUTES", "routes")
	boutons_construction = HBoxContainer.new()
	boutons_construction.add_theme_constant_override("separation", 8)
	colonne.add_child(boutons_construction)
	libelle_message = Label.new()
	libelle_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	libelle_message.add_theme_color_override("font_color", Color("ffd166"))
	colonne.add_child(libelle_message)

func _actualiser() -> void:
	if not is_instance_valid(libelle_ressources):
		return
	libelle_ressources.text = "Bois : %d/%d     Pierre : %d/%d     Habitants : %d     Station : niv. %d" % [jeu.bois, jeu.capacite, jeu.pierre, jeu.capacite, jeu.ouvriers.size(), jeu.niveau_station]
	libelle_message.text = message
	_reconstruire_boutons_habitants()
	_reconstruire_boutons_construction()
	queue_redraw()

func _reconstruire_boutons_habitants() -> void:
	for enfant in boutons_habitants.get_children(): enfant.queue_free()
	for index in jeu.ouvriers.size():
		var cible: Vector2i = jeu.ouvriers[index].cible
		var statut := "sans tâche" if cible == Vector2i(-1, -1) else ("en route" if jeu.ouvriers[index].en_deplacement else "récolte")
		var bouton := Button.new()
		bouton.text = "%s — %s" % [jeu.ouvriers[index].nom, statut]
		bouton.custom_minimum_size = Vector2(190, 38)
		bouton.pressed.connect(func() -> void:
			habitant_selectionne = index
			mode = ""
			message = "Touchez un cube arbre ou rocher pour assigner %s." % jeu.ouvriers[index].nom
			_actualiser())
		boutons_habitants.add_child(bouton)

func _reconstruire_boutons_construction() -> void:
	for enfant in boutons_construction.get_children(): enfant.queue_free()
	match categorie_active:
		"batiments":
			_ajouter_bouton("Scierie — 20 bois", "scierie")
			_ajouter_bouton("Entrepôt — 35 bois, 25 pierre", "entrepot")
			_ajouter_bouton("Améliorer la station — 100 bois, 75 pierre", "station_niv2")
		"habitations":
			_ajouter_bouton("Maison — 50 bois, 15 pierre", "maison")
		"recolte":
			_ajouter_bouton("Carrière — 30 bois (scierie requise)", "carriere")
		"routes":
			_ajouter_bouton("Poser une tuile — 1 bois", "route")
			_ajouter_bouton("Supprimer une tuile", "suppression_route")

func _ajouter_bouton(texte: String, type: String) -> void:
	var bouton := Button.new()
	bouton.text = texte
	bouton.custom_minimum_size = Vector2(260, 34)
	bouton.pressed.connect(func() -> void:
		mode = type
		habitant_selectionne = -1
		message = "Mode %s : touchez une case libre." % ("route" if type == "route" else "construction")
		if type == "station_niv2":
			message = jeu.construire(type, Vector2i.ZERO)
			mode = ""
		_actualiser())
	boutons_construction.add_child(bouton)

func _ajouter_categorie(conteneur: HBoxContainer, texte: String, categorie: String) -> void:
	var bouton := Button.new()
	bouton.text = texte
	bouton.icon = {
		"batiments": ICONE_BATIMENTS,
		"habitations": ICONE_HABITATIONS,
		"recolte": ICONE_RECOLTE,
		"routes": ICONE_ROUTES,
	}[categorie]
	bouton.expand_icon = true
	bouton.add_theme_constant_override("icon_max_width", 34)
	bouton.alignment = HORIZONTAL_ALIGNMENT_CENTER
	bouton.custom_minimum_size = Vector2(290, 42)
	bouton.pressed.connect(func() -> void:
		categorie_active = categorie
		mode = ""
		habitant_selectionne = -1
		message = "%s : choisissez une construction." % texte.capitalize()
		_actualiser())
	conteneur.add_child(bouton)

func _draw() -> void:
	if jeu == null:
		return
	# Le fond et les ouvriers sont issus des références visuelles du dossier DESIGN.
	draw_texture_rect(ARRIERE_PLAN, Rect2(0, 0, 1280, 720), false)
	draw_rect(Rect2(0, 0, 1280, 480), Color(0.08, 0.19, 0.10, 0.16), true)
	draw_string(ThemeDB.fallback_font, Vector2(28, 36), "Terrain de la ville — sélectionnez une construction dans la barre inférieure", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	for y in jeu.TAILLE_GRILLE.y:
		for x in jeu.TAILLE_GRILLE.x:
			var rect := Rect2(ORIGINE + Vector2(x, y) * TAILLE_CASE, Vector2(TAILLE_CASE - 3, TAILLE_CASE - 3))
			draw_rect(rect, Color(0.12, 0.35, 0.20, 0.27), true)
			draw_rect(rect, Color(0.75, 0.93, 0.69, 0.60), false, 1.5)
	for case_ in jeu.routes:
		_dessiner_route(case_)
	for case_ in jeu.ressources:
		if jeu.ressources[case_] == "arbre":
			_dessiner_conifere(case_, _arbre_est_recolte(case_))
		else:
			_dessiner_cube(case_, Color("8c9099"), "R")
	for case_ in jeu.batiments:
		var type: String = jeu.batiments[case_]
		var couleur := Color("4361ee") if type == "station" else Color("e76f51")
		_dessiner_cube(case_, couleur, {"station": "S%d" % jeu.niveau_station, "scierie": "SCI", "carriere": "CAR", "maison": "MAI", "entrepot": "ENT"}.get(type, "?"))
	for index in jeu.ouvriers.size():
		var position_grille: Vector2 = jeu.ouvriers[index].position
		var position := ORIGINE + position_grille * TAILLE_CASE
		_dessiner_ouvrier(position, index + 1, jeu.ouvriers[index])

func _dessiner_cube(case_: Vector2i, couleur: Color, texte: String) -> void:
	var rect := Rect2(ORIGINE + Vector2(case_) * TAILLE_CASE + Vector2(8, 8), Vector2(TAILLE_CASE - 19, TAILLE_CASE - 19))
	draw_rect(rect, couleur, true)
	draw_rect(rect, Color("17202a"), false, 2)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 27), texte, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

func _dessiner_conifere(case_: Vector2i, est_recolte: bool) -> void:
	var centre := ORIGINE + Vector2(case_) * TAILLE_CASE + Vector2(TAILLE_CASE / 2.0, TAILLE_CASE - 2)
	if est_recolte:
		var largeur_frame := ANIMATION_CONIFERE_COUPE.get_width() / 5.0
		var index_frame := int(temps_animation * 1.5) % 5
		var source := Rect2(index_frame * largeur_frame, 0, largeur_frame, ANIMATION_CONIFERE_COUPE.get_height())
		var destination_animation := Rect2(centre - Vector2(52, 112), Vector2(104, 112))
		draw_texture_rect_region(ANIMATION_CONIFERE_COUPE, destination_animation, source)
	else:
		var destination := Rect2(centre - Vector2(40, 112), Vector2(80, 112))
		draw_texture_rect(SPRITE_CONIFERE, destination, false)
	var etiquette := Rect2(centre + Vector2(-10, -14), Vector2(20, 20))
	draw_rect(etiquette, Color("174d33"), true)
	draw_rect(etiquette, Color("d8f3dc"), false, 1)
	draw_string(ThemeDB.fallback_font, etiquette.position + Vector2(6, 15), "A", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

func _dessiner_route(case_: Vector2i) -> void:
	var masque := 0
	if jeu.routes.has(case_ + Vector2i.UP): masque |= 1
	if jeu.routes.has(case_ + Vector2i.RIGHT): masque |= 2
	if jeu.routes.has(case_ + Vector2i.DOWN): masque |= 4
	if jeu.routes.has(case_ + Vector2i.LEFT): masque |= 8
	# Indices dans la planche 4 × 4 : ligne, angle, T et croisement.
	var indices := {0: 0, 5: 5, 10: 6, 3: 7, 6: 10, 12: 8, 9: 9, 7: 12, 11: 13, 13: 14, 14: 15, 15: 15}
	var index_tuile: int = indices.get(masque, 0)
	var largeur_tuile := TUILES_ROUTE.get_width() / 4.0
	var hauteur_tuile := TUILES_ROUTE.get_height() / 4.0
	var source := Rect2((index_tuile % 4) * largeur_tuile, (index_tuile / 4) * hauteur_tuile, largeur_tuile, hauteur_tuile)
	# La tuile déborde très légèrement afin de recouvrir toute la case sans joint visible.
	var destination := Rect2(ORIGINE + Vector2(case_) * TAILLE_CASE - Vector2(1, 1), Vector2(TAILLE_CASE + 2, TAILLE_CASE + 2))
	draw_texture_rect_region(TUILES_ROUTE, destination, source)

func _arbre_est_recolte(case_: Vector2i) -> bool:
	for ouvrier in jeu.ouvriers:
		if ouvrier.cible == case_ and not ouvrier.en_deplacement:
			return true
	return false

func _dessiner_ouvrier(position: Vector2, numero: int, ouvrier: Dictionary) -> void:
	var largeur_image := SPRITE_OUVRIER.get_width() / 3.0
	var hauteur_image := SPRITE_OUVRIER.get_height() / 4.0
	var lignes := {"bas": 0, "droite": 1, "haut": 2, "gauche": 3}
	var colonne := int(temps_animation * 8.0) % 3 if ouvrier.en_deplacement else 1
	var ligne: int = lignes.get(ouvrier.direction, 0)
	var source := Rect2(colonne * largeur_image, ligne * hauteur_image, largeur_image, hauteur_image)
	var destination := Rect2(position - Vector2(22, 54), Vector2(44, 58))
	draw_texture_rect_region(SPRITE_OUVRIER, destination, source)
	draw_circle(position + Vector2(16, -45), 9, Color("f4d35e"))
	draw_string(ThemeDB.fallback_font, position + Vector2(13, -41), str(numero), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("17202a"))
