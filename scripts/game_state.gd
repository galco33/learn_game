class_name EtatJeu
extends RefCounted

signal etat_modifie

const TAILLE_GRILLE := Vector2i(8, 8)
const COUT_ROUTE := 1
const COUTS := {
	"scierie": {"bois": 20, "pierre": 0},
	"carriere": {"bois": 30, "pierre": 0},
	"maison": {"bois": 50, "pierre": 15},
	"entrepot": {"bois": 35, "pierre": 25},
	"station_niv2": {"bois": 100, "pierre": 75},
}

var bois := 0
var pierre := 0
var capacite := 100
var niveau_station := 1
var ouvriers: Array[Dictionary] = []
var routes: Array[Vector2i] = []
var batiments: Dictionary = {}
var ressources: Dictionary = {
	Vector2i(1, 2): "arbre",
	Vector2i(2, 5): "arbre",
	Vector2i(5, 1): "arbre",
	Vector2i(6, 5): "rocher",
	Vector2i(5, 6): "rocher",
}

func _init() -> void:
	batiments[Vector2i(3, 3)] = "station"
	for index in 2:
		ouvriers.append(_creer_ouvrier(index))

func est_dans_grille(case_: Vector2i) -> bool:
	return case_.x >= 0 and case_.y >= 0 and case_.x < TAILLE_GRILLE.x and case_.y < TAILLE_GRILLE.y

func est_libre(case_: Vector2i) -> bool:
	return est_dans_grille(case_) and not batiments.has(case_) and not ressources.has(case_) and not routes.has(case_)

func peut_construire(type: String) -> bool:
	if type == "carriere" and not batiments.values().has("scierie"):
		return false
	if type == "station_niv2":
		return niveau_station == 1
	if not COUTS.has(type):
		return false
	var cout: Dictionary = COUTS[type]
	return bois >= cout.bois and pierre >= cout.pierre

func construire(type: String, case_: Vector2i) -> String:
	if type == "station_niv2":
		if not peut_construire(type):
			return "La station ne peut pas encore être améliorée."
		_depense(COUTS[type])
		niveau_station = 2
		etat_modifie.emit()
		return "Station de construction améliorée au niveau 2 !"
	if not est_libre(case_):
		return "Cette case est déjà occupée."
	if not peut_construire(type):
		if type == "carriere":
			return "Construisez d'abord une scierie pour débloquer la carrière."
		return "Ressources insuffisantes."
	_depense(COUTS[type])
	batiments[case_] = type
	if type == "maison":
		ouvriers.append(_creer_ouvrier(ouvriers.size()))
	if type == "entrepot":
		capacite += 100
	etat_modifie.emit()
	return "%s construit." % _nom(type)

func placer_route(case_: Vector2i) -> String:
	if not est_dans_grille(case_) or batiments.has(case_) or ressources.has(case_):
		return "Impossible de poser une route ici."
	if routes.has(case_):
		return "Une route est déjà présente."
	if bois < COUT_ROUTE:
		return "Il faut 1 bois pour cette route."
	bois -= COUT_ROUTE
	routes.append(case_)
	etat_modifie.emit()
	return "Route posée : les déplacements qui l'utilisent sont plus rapides."

func retirer_route(case_: Vector2i) -> String:
	if not routes.has(case_):
		return "Il n'y a aucune route à supprimer ici."
	routes.erase(case_)
	bois = min(capacite, bois + COUT_ROUTE)
	etat_modifie.emit()
	return "Route supprimée : 1 bois récupéré."

func assigner(index: int, case_: Vector2i) -> String:
	if index < 0 or index >= ouvriers.size():
		return "Sélectionnez un habitant."
	if not ressources.has(case_):
		return "Touchez un arbre ou un rocher pour l'assigner."
	if ressources[case_] == "rocher" and not batiments.values().has("carriere"):
		return "La carrière est nécessaire pour récolter la pierre."
	ouvriers[index].cible = case_
	ouvriers[index].progres = 0.0
	ouvriers[index].en_deplacement = true
	etat_modifie.emit()
	return "%s part vers %s." % [ouvriers[index].nom, ressources[case_]]

func produire(delta: float) -> void:
	var modifie := false
	var arrivee := false
	for ouvrier in ouvriers:
		if _deplacer_ouvrier(ouvrier, delta):
			arrivee = true
		if ouvrier.en_deplacement:
			continue
		if ouvrier.cible == Vector2i(-1, -1):
			continue
		var type: String = ressources.get(ouvrier.cible, "")
		if type.is_empty():
			continue
		var duree := 3.0 if type == "arbre" else 4.0
		# La proximité d'une route représente un aller-retour plus court.
		if _cible_pres_de_route(ouvrier.cible):
			duree /= 1.5
		ouvrier.progres += delta
		while ouvrier.progres >= duree:
			ouvrier.progres -= duree
			if type == "arbre" and bois < capacite:
				bois += 1
				modifie = true
			elif type == "rocher" and pierre < capacite:
				pierre += 1
				modifie = true
	if batiments.values().has("scierie") and bois < capacite:
		var production_scierie: float = delta / 3.0
		# Le reliquat rend la production automatique stable sans dépendre des FPS.
		_scierie_reliquat += production_scierie
		if _scierie_reliquat >= 1.0:
			var gain := int(_scierie_reliquat)
			bois = min(capacite, bois + gain)
			_scierie_reliquat -= gain
			modifie = true
	if modifie or arrivee:
		etat_modifie.emit()

var _scierie_reliquat := 0.0

func _cible_pres_de_route(case_: Vector2i) -> bool:
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if routes.has(case_ + direction):
			return true
	return false

func _creer_ouvrier(index: int) -> Dictionary:
	return {
		"nom": "Habitant %d" % (index + 1),
		"cible": Vector2i(-1, -1),
		"progres": 0.0,
		"position": Vector2(3.35 + float(index % 2) * 0.30, 3.55),
		"direction": "bas",
		"en_deplacement": false,
	}

func _deplacer_ouvrier(ouvrier: Dictionary, delta: float) -> bool:
	if not ouvrier.en_deplacement or ouvrier.cible == Vector2i(-1, -1):
		return false
	var destination := Vector2(_case_a_cote_de_ressource(ouvrier.cible)) + Vector2(0.5, 0.5)
	var vecteur: Vector2 = destination - ouvrier.position
	var distance := vecteur.length()
	var vitesse := 1.25
	if _cible_pres_de_route(ouvrier.cible):
		vitesse *= 1.5
	if distance <= vitesse * delta:
		ouvrier.position = destination
		ouvrier.en_deplacement = false
		return true
	var direction: Vector2 = vecteur.normalized()
	ouvrier.position += direction * vitesse * delta
	if abs(direction.x) > abs(direction.y):
		ouvrier.direction = "droite" if direction.x > 0.0 else "gauche"
	else:
		ouvrier.direction = "bas" if direction.y > 0.0 else "haut"
	return false

func _case_a_cote_de_ressource(ressource: Vector2i) -> Vector2i:
	# L'ouvrier se place entre la station et sa cible, jamais sur la ressource.
	var vers_station := Vector2i(3, 3) - ressource
	var decalage := Vector2i.RIGHT if abs(vers_station.x) > abs(vers_station.y) else Vector2i.DOWN
	if abs(vers_station.x) > abs(vers_station.y):
		decalage.x = 1 if vers_station.x > 0 else -1
	else:
		decalage.y = 1 if vers_station.y > 0 else -1
	var case_adjacente := ressource + decalage
	return case_adjacente if est_dans_grille(case_adjacente) else ressource

func _depense(cout: Dictionary) -> void:
	bois -= int(cout.bois)
	pierre -= int(cout.pierre)

func _nom(type: String) -> String:
	return {"scierie": "Scierie", "carriere": "Carrière", "maison": "Maison", "entrepot": "Entrepôt"}.get(type, type)
