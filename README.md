# Ville idle — MVP mécanique

Prototype Godot 4 jouable du MVP. Il représente la ville avec des cases, des
cubes et des lignes afin de valider la boucle de production avant tout travail
graphique.

## Lancer

1. Ouvrir le dossier dans Godot 4.
2. Lancer la scène principale (`F6` ou `F5`).
3. Choisir un habitant dans le panneau, puis cliquer un cube `A` (arbre).
4. Construire une scierie, puis une carrière pour affecter des habitants aux
   cubes `R` (rochers). Les routes coûtent 1 bois et accélèrent la récolte
   adjacente.

Un habitant peut être réaffecté à tout moment : sélectionnez-le de nouveau,
puis touchez l'arbre ou le rocher qui devient sa nouvelle tâche.
Il marche visiblement jusqu'à sa cible avant de commencer à récolter.
Les arbres sont des conifères et l'habitant s'arrête sur une case voisine pour
les récolter, afin de rester visible.
Lorsqu'un habitant récolte du bois, le conifère affiche son animation de coupe.

La barre de construction en bas de l'écran regroupe les catégories
**Bâtiments**, **Habitations**, **Bâtiments de récolte** et **Routes**. La
catégorie Routes permet de poser une tuile (1 bois) ou d'en supprimer une ; la
suppression restitue son bois et les visuels de ligne, angle et croisement
s'adaptent aux routes voisines.

La cible de la première partie est d'améliorer la station au niveau 2. Les
contrôles sont utilisables à la souris et les boutons ont des dimensions
compatibles avec un usage tactile.

## Périmètre actuel

- Grille 8 × 8, station, arbres et rochers.
- Deux habitants assignables, récolte périodique et plafond de stockage.
- Routes, scierie, carrière, maison, entrepôt et station niveau 2.
- Aucun asset graphique : la carte est dessinée directement par code.

La sauvegarde, les déplacements visibles et les exports mobiles restent à
ajouter après validation de cette boucle.
