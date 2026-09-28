# Socle technique — Godot mobile

## Décision

Le jeu sera développé avec **Godot 4**, en visant d'abord Android et iOS. Le
projet doit rester exécutable sur ordinateur pour faciliter le développement,
les tests et les itérations rapides.

Godot convient au projet car il permet de construire une interface 2D tactile,
une carte isométrique et une sauvegarde locale sans dépendre d'un moteur ou de
services externes complexes.

## Cible du premier incrément

Un prototype mobile doit permettre, au minimum, de :

1. naviguer sur une petite carte isométrique ;
2. sélectionner une case au toucher ;
3. placer un bâtiment et une route ;
4. voir les compteurs de ressources évoluer ;
5. recommencer une partie sans état incohérent.

La performance cible est une interface fluide sur un téléphone milieu de gamme,
avec une carte petite à moyenne. L'optimisation d'une grande ville est reportée
tant que la boucle MVP n'est pas validée.

## Architecture proposée

Séparer les données de jeu de leur représentation visuelle. Une production de
ressources ou un réseau électrique doit pouvoir être testé sans lancer une
scène Godot complète.

```text
Autoload GameState
  ├─ Données : ressources, habitants, bâtiments, grille, réseaux
  ├─ Règles : coûts, placement, production, connectivité
  └─ Sauvegarde : à ajouter après le MVP

Main (scène)
  ├─ World : carte isométrique, bâtiments, routes, habitants
  ├─ Camera2D : glissement et zoom tactile
  └─ CanvasLayer : compteurs, barre de construction, panneau contextuel
```

### Responsabilités

- **GameState :** source unique de vérité ; aucune ressource ne doit être
  modifiée directement par un bouton ou un sprite.
- **Grille :** valide les cases, empreintes, occupations et voisins ; elle ne
  dépend pas de l'affichage isométrique.
- **World :** transforme les données de grille en tuiles, routes et bâtiments
  visibles.
- **Interface :** demande une action au modèle puis affiche le résultat et une
  erreur compréhensible si elle est impossible.
- **Réseaux futurs :** utilisent des données génériques de nœuds et de liens,
  indépendantes des sprites de poteaux, câbles et conduites.

## Choix Godot à privilégier

- `TileMapLayer` pour le sol et la grille isométrique.
- Scènes réutilisables pour les bâtiments, habitants, poteaux et sources de
  service.
- `Camera2D` pour le déplacement et le zoom.
- `CanvasLayer` et nœuds `Control` pour l'interface qui reste fixe à l'écran.
- Signaux pour annoncer les changements d'état à l'interface et au monde.
- GDScript pour le MVP : il est suffisant, rapide à itérer et bien intégré à
  Godot.

Ne pas choisir de plugin, de système ECS ni de service en ligne avant qu'un
besoin concret ne le justifie.

## Exigences tactiles et accessibilité

- Prévoir des cibles tactiles confortables et espacées.
- Afficher texte, icônes et compteurs de manière lisible sur petit écran.
- Ne pas réserver une action importante à un geste difficile à découvrir.
- Toujours fournir un retour visuel sur une case, un coût ou une action
  impossible.
- Tester en résolution mobile dès le premier prototype, pas seulement dans la
  fenêtre desktop de l'éditeur.

## Vérifications attendues de l'agent Développement

À chaque lot, l'agent doit :

1. lancer le projet Godot sans erreur de script ;
2. tester manuellement le parcours tactile concerné ;
3. exécuter les tests de logique ajoutés au projet ;
4. vérifier au moins une résolution mobile de référence ;
5. signaler explicitement les appareils ou exports non testés.

## À décider avant le premier projet exportable

- Résolution de référence et orientations prises en charge (portrait,
  paysage, ou les deux).
- Android seul au départ, ou Android et iOS dès le premier export.
- Méthode de sauvegarde locale et durée maximale des gains hors-ligne.
- Style visuel des tuiles et échelle des bâtiments pour conserver une ville
  lisible sur téléphone.
