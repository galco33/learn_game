# Game design — Ville moderne idle

Ce document transforme l'idée du jeu en décisions de conception et en travail
priorisé pour l'agent Développement. Il complète le MVP existant dans
[`DOC/mvp/mvp.md`](../mvp/mvp.md) : ce fichier est la référence pour les
intentions, les règles et l'ordre des fonctionnalités.

**Choix technique validé :** le jeu sera réalisé avec Godot 4 et ciblé d'abord
pour les appareils mobiles. Le détail de l'organisation technique est dans
[`DOC/technique/godot-mobile.md`](../technique/godot-mobile.md).

## 1. Vision du jeu

Le joueur fait grandir, sur plusieurs jours, une ville moderne en vue
isométrique. Il place librement des bâtiments, des routes et, plus tard, les
infrastructures qui les alimentent. Il commence avec une station de construction
et quelques ressources naturelles, puis construit une économie urbaine de plus
en plus grande et autonome.

**Promesse joueur :** « J'ai transformé un terrain presque vide en une ville
moderne, organisée et autonome. »

### Principes directeurs

- Les choix sont simples à comprendre : assigner, construire, améliorer.
- La ville se construit sur une grille visible et lisible en vue isométrique.
- Le placement libre permet au joueur de donner sa forme à la ville, sans
  l'enfermer dans un exercice de précision.
- L'interface est pensée pour le tactile : les actions importantes restent
  accessibles au pouce et les informations sont lisibles sur petit écran.
- Les réseaux (routes, eau, électricité) doivent rendre la planification plus
  intéressante, jamais simplement punitive.
- Toute action doit avoir un résultat visible rapidement (production, nouveau
  bâtiment ou nouvel habitant).
- L'automatisation est une récompense : elle libère le joueur, sans supprimer
  totalement les décisions.
- Le jeu reste lisible : peu de ressources et peu de bâtiments au début.
- Le MVP valide avant tout le plaisir de voir le village prendre vie.

## 2. Périmètre du MVP

### Inclus

- Une carte unique en vue isométrique, composée de cases constructibles.
- Une station de construction présente dès le début : elle est le point de
  départ de la future ville et le premier jalon d'évolution.
- Des arbres et rochers répartis sur la carte comme premiers lieux de récolte.
- Le placement libre de bâtiments sur des cases libres et la construction de
  routes case par case.
- Deux ressources : bois et pierre.
- Des habitants assignables aux tâches de récolte.
- Quatre bâtiments : scierie, carrière, maison et entrepôt.
- Un premier jalon : améliorer la station de construction au niveau 2.
- Une première session guidée de 15 à 30 minutes, puis une ville persistante
  qui continue de grandir sans objectif de fin.

### Explicitement reporté après validation du MVP

- Combat, ennemis et défense.
- Météo, saisons, faim, soif et bonheur des habitants.
- Commerce, quêtes complexes, multijoueur et grande carte.
- Arbre technologique étendu, dizaines de ressources et chaînes de production
  longues.
- Les contraintes d'eau et d'électricité : elles sont prévues dans le modèle de
  données mais ne bloquent pas le premier test de la boucle de jeu.

## 3. Boucle de jeu

```text
Observer les besoins → assigner les habitants → obtenir des ressources
        ↑                                              ↓
planifier la ville ← construire / relier ← débloquer une option
```

La boucle doit s'alterner entre de petites décisions immédiates (qui récolte
quoi ? où prolonger une route ?) et des objectifs visibles à moyen terme
(atteindre le coût du prochain bâtiment et organiser le prochain quartier).

## 4. Construction et lisibilité de la ville

### Grille isométrique

La carte est une grille de cases. Un bâtiment ou un élément d'infrastructure
occupe une ou plusieurs cases ; une case ne peut contenir qu'un élément au sol
sauf règle contraire explicite. Le jeu met en surbrillance :

- les cases libres et constructibles ;
- l'empreinte du bâtiment avant confirmation ;
- les cases bloquées, avec une raison claire ;
- le tracé d'une route ou d'une ligne en cours de placement.

### Légende des schémas et prototypes

Les schémas de conception utilisent les abréviations suivantes. Elles servent
uniquement à rendre une carte ou un plan compact ; dans le jeu, l'interface
affichera des icônes et des noms complets.

| Symbole | Signification | Rôle |
| --- | --- | --- |
| `A` | Arbre | Lieu de récolte de bois |
| `R` | Rocher | Lieu de récolte de pierre |
| `S1` | Station de construction, niveau 1 | Bâtiment initial et point de départ de la ville |
| `S2` | Station de construction, niveau 2 | Premier palier d'évolution de la ville |
| `P1`, `P2` | PNJ 1, PNJ 2 | Habitants assignables à une tâche |
| `Rt` | Route | Case praticable qui accélère les déplacements des PNJ |
| `Sc` | Scierie | Bâtiment de production automatique de bois |
| `Ca` | Carrière | Bâtiment qui permet la récolte de pierre |
| `M` | Maison | Bâtiment qui ajoute un PNJ |
| `E` | Entrepôt | Bâtiment qui augmente le stockage |

Exemple de départ :

```text
[A] [A] [ ] [R] [R]
[ ] [Rt][Rt][Rt][ ]
[ ] [P1][S1][P2][ ]
```

Dans cet exemple, `S1` est bien la **station de construction de niveau 1**,
et non une ressource. Les PNJ partent de cette zone, empruntent les routes si
elles sont utiles, puis peuvent être affectés aux arbres ou aux rochers.

Le placement doit rester souple : annulation avant validation, suppression ou
déplacement récupérable pendant le MVP, et aucun coût caché. La caméra doit
préserver la lecture des bâtiments, même lorsque le village se densifie.

### Contrôles mobiles

- Un toucher sélectionne une case, un bâtiment ou un habitant.
- Un glissement déplace la caméra ; le pincement zoome et dézoome.
- Le mode construction montre une prévisualisation sous le doigt avant une
  confirmation explicite.
- Le tracé de route et de ligne électrique accepte un glissement continu sur
  les cases ; il montre le coût total avant la validation.
- Une sélection affiche un panneau contextuel compact, plutôt qu'une fenêtre
  qui masque la ville.

Le MVP doit pouvoir se jouer entièrement au tactile. Les contrôles souris et
clavier peuvent exister pour accélérer les tests sur ordinateur, mais ne doivent
pas dicter le design de l'interface.

### Routes

Les routes sont des éléments posés case par case et sont indispensables au
développement efficace de la ville. Au début, les PNJ peuvent marcher sur
l'herbe pour aller récolter un arbre ou un rocher. Lorsqu'une route relie leur
trajet, ils se déplacent plus vite : elle réduit donc le temps de trajet entre
la station de construction, les lieux de récolte et les futurs bâtiments.

Les routes n'ont pas besoin d'être obligatoires pour poser le tout premier
bâtiment, mais elles deviennent le moyen naturel de relier et d'optimiser les
quartiers. Elles prépareront également les futurs réseaux d'eau et
d'électricité.

Valeur de départ proposée : **1 bois par case de route**. Ce coût est à tester,
car les routes doivent encourager la planification sans ralentir la partie.

**Hypothèse de départ à tester :** vitesse sur route = 150 % de la vitesse sur
l'herbe. Le bonus doit être immédiatement perceptible, sans rendre les chemins
hors route inutilisables.

### Règle de voisinage à retenir

Pour les futurs systèmes urbains, un bâtiment est considéré « desservi » si au
moins une de ses cases touche orthogonalement une case de route. Cette règle,
simple et visible, reliera naturellement les bâtiments aux réseaux sans
demander de placer un câble sur chaque bâtiment.

## 5. Règles de départ proposées

Ces valeurs sont une première hypothèse d'équilibrage, à tester en jeu. Elles
ne sont pas définitives.

### État initial

| Élément | Valeur |
| --- | ---: |
| Station de construction | Niveau 1, déjà construite |
| Habitants | 2 |
| Bois | 0 |
| Pierre | 0 |
| Capacité de base par ressource | 100 |
| Production manuelle de bois | 1 bois / habitant / 3 s |
| Production manuelle de pierre | 1 pierre / habitant / 4 s |

La carrière n'est disponible qu'après la construction de la scierie. Ainsi, le
joueur apprend d'abord le cycle bois et comprend ensuite le même principe avec
la pierre.

### Bâtiments et jalons

| Bâtiment | Coût | Effet | Rôle dans la progression |
| --- | --- | --- | --- |
| Scierie | 20 bois | Produit 1 bois / 3 s automatiquement | Première automatisation et déblocage de la carrière |
| Carrière | 30 bois | Permet d'assigner des habitants à la pierre | Introduit la seconde ressource |
| Maison | 50 bois, 15 pierre | Ajoute 1 habitant | Augmente les choix d'assignation |
| Entrepôt | 35 bois, 25 pierre | +100 de capacité pour chaque ressource | Évite de perdre la production et prépare le premier jalon |
| Station de construction niv. 2 | 100 bois, 75 pierre | Débloque le palier de développement suivant | Premier jalon, sans fin de partie |

### Rythme ciblé

- **0–3 min :** récolter le bois, tracer les premières routes utiles et
  construire la scierie.
- **3–8 min :** accumuler du bois, construire la carrière et produire la
  pierre.
- **8–18 min :** construire une maison, arbitrer les affectations et augmenter
  les stocks.
- **18–30 min :** construire l'entrepôt puis améliorer la station de
  construction au niveau 2.

Si le joueur attend plus de 20 à 30 secondes sans action utile ni anticipation
intéressante, il faut revoir coûts, cadence ou nouveaux choix disponibles.

## 6. Décisions et retours attendus du joueur

### Décisions utiles

- Envoyer tous les habitants au bois pour atteindre rapidement un coût, ou
  répartir les travailleurs pour préparer le prochain besoin.
- Réaffecter librement un PNJ du bois vers la pierre, ou inversement, lorsque
  le besoin de ressources change.
- Construire une maison dès que possible, ou privilégier l'entrepôt afin de ne
  pas saturer les stocks.

### Règle d'affectation des PNJ

Un PNJ possède une tâche active : `sans tâche`, `bois` ou `pierre`. Le joueur
peut modifier cette tâche à tout moment depuis le PNJ ou le lieu de récolte.

Lors d'un changement bois → pierre (ou pierre → bois), le PNJ termine son action
en cours si elle est déjà engagée, puis se dirige vers le nouveau lieu de
récolte. Il ne doit jamais produire les deux ressources simultanément ni
disparaître de la carte. L'interface doit afficher sa tâche actuelle et le
nouveau trajet afin que la réaffectation soit immédiatement compréhensible.

La réaffectation ne coûte aucune ressource au MVP. Le seul coût est le temps de
déplacement ; les routes rendent donc aussi cette décision plus efficace.

### Retours visuels et sonores à prévoir

- Un habitant se déplace vers sa tâche et montre clairement son état assigné.
- Chaque récolte actualise la ressource et produit un retour discret à l'écran.
- La grille indique coût, disponibilité et emplacement du bâtiment choisi.
- Le tracé des routes se voit avant sa validation et les cases invalides sont
  distinguées sans ambiguïté.
- Une construction terminée modifie visiblement le village.
- Une ressource pleine avertit sans bloquer l'interface silencieusement.

Ces retours sont importants : un jeu idle est satisfaisant lorsqu'il rend la
croissance évidente, même pendant les moments sans clic.

## 7. Équilibrage à mesurer avant d'ajouter du contenu

Pendant les premiers tests, relever :

- le temps pour construire chaque bâtiment ;
- le nombre de réassignations volontaires des habitants ;
- le temps passé avec un stock plein ;
- les moments où le joueur ne sait pas quoi faire ;
- le temps total jusqu'à la station de construction niveau 2 ;
- la différence de durée de trajet sur route et sur herbe ;
- si le joueur comprend spontanément pourquoi une option est bloquée.

Critères de réussite du MVP : un nouveau joueur comprend la boucle sans guide
long, a au moins deux décisions d'affectation significatives, et termine avec
l'impression que la ville est devenue plus autonome.

## 8. Backlog pour l'agent Développement

L'ordre ci-dessous limite les dépendances et permet de tester le plaisir du jeu
le plus tôt possible.

### Lot 1 — Socle jouable

1. Initialiser le projet Godot et définir la scène principale, les paramètres
   mobiles et la résolution de référence.
2. Créer l'état de partie : ressources, capacité, habitants, affectations,
   bâtiments, grille et éléments de réseau.
3. Afficher les compteurs de bois, pierre et habitants dans une interface
   adaptée au tactile.
4. Créer une carte isométrique, avec sélection tactile d'une case, déplacement
   de caméra et affichage des cases libres ou bloquées.
5. Créer la station de construction, les arbres et les rochers comme objets de
   carte ; créer l'assignation, la désassignation et la réaffectation d'un PNJ
   entre bois et pierre.
6. Mettre en place la boucle de production périodique, les déplacements de PNJ
   sur l'herbe et le plafond de capacité de stockage.
7. Ajouter des tests unitaires pour la production, les capacités, les
   affectations, les réaffectations et la validation d'occupation de la grille.

**Validation :** un PNJ peut passer du bois à la pierre, se rendre vers le bon
lieu de récolte et ne produire qu'une ressource à la fois. Deux habitants
peuvent produire du bois depuis des arbres, revenir à la station de
construction et la production s'arrête proprement au plafond de stockage.

### Lot 2 — Bâtiments et déblocages

1. Ajouter le placement et le retrait de routes sur la grille.
2. Calculer le trajet des PNJ et appliquer le bonus de vitesse lorsque le trajet
   utilise des routes.
3. Ajouter le placement libre de bâtiments et une action de construction.
4. Implémenter la vérification des coûts, de l'empreinte et le retrait des
   ressources.
5. Ajouter la scierie avec sa production automatique.
6. Débloquer la carrière après la scierie, puis permettre la récolte de pierre.
7. Présenter clairement les coûts et conditions de déblocage dans l'interface.

**Validation :** le chemin bois → routes rapides → scierie → carrière → pierre
peut être joué sans état incohérent, dépense négative ni PNJ bloqué.

### Lot 3 — Progression complète

1. Ajouter la maison, avec l'apparition fiable d'un nouvel habitant.
2. Ajouter l'entrepôt et l'augmentation de capacité.
3. Ajouter la station de construction niveau 2, avec un message de nouveau
   palier sans écran de fin de partie.
4. Enregistrer des métriques locales de test (temps des jalons et stocks
   pleins), si l'architecture le permet sans alourdir le MVP.
5. Effectuer une passe d'équilibrage à partir de parties réelles.

**Validation :** le premier jalon est atteignable en 15 à 30 minutes et la
partie peut continuer au-delà sans état de fin.

### Lot 4 — Qualité et persistance

1. Ajouter la sauvegarde locale de l'état de ville dès que le premier jalon est
   jouable ; elle est nécessaire au principe de ville persistante.
2. Ajouter un tutoriel contextuel très court, uniquement si les tests montrent
   un blocage de compréhension.
3. Calculer les gains hors-ligne avec une durée maximale plafonnée et un écran
   de résumé au retour.
4. Tester les migrations de sauvegarde et les cas de données absentes ou
   corrompues.

## 9. Services urbains : eau et électricité

Les services urbains font partie de la vision à long terme, mais leur design
détaillé est volontairement reporté. La priorité actuelle est de valider la
croissance de la ville, les déplacements des PNJ et la valeur des routes.

### Intention conservée

- L'eau et l'électricité devront créer des choix de planification de quartiers.
- Les routes serviront de structure naturelle pour organiser ces réseaux.
- L'interface devra toujours rendre une connexion, une couverture ou un manque
  de service compréhensible.

Les choix de centrales, poteaux, lignes, conduites, portées, coûts,
consommations et conséquences d'un manque d'électricité seront décidés plus
tard, ensemble, avant qu'un agent Développement ne les implémente.

### Lot réservé — Services urbains

À ne pas démarrer avant une décision de game design dédiée. L'agent
Développement doit seulement veiller à ce que routes, bâtiments et grille aient
des données de position suffisamment propres pour accueillir ces systèmes.

## 10. Pistes après le MVP

Ajouter une seule famille de fonctionnalités à la fois, seulement si le MVP est
déjà plaisant :

| Direction | Exemple | Question à valider |
| --- | --- | --- |
| Profondeur économique | Argile puis briqueterie | Apporte-t-elle un choix, plutôt qu'une simple attente ? |
| Progression | Améliorations limitées par bâtiment | Les joueurs veulent-ils spécialiser leur village ? |
| Exploration | Deuxième zone à débloquer | La première zone est-elle déjà assez claire et satisfaisante ? |
| Objectifs | Petites commandes de village | Donnent-elles une direction sans imposer de routine ? |
| Esthétique vivante | Animations, variantes de bâtiments | Renforcent-elles la sensation de croissance ? |
| Services urbains | Éoliennes, panneaux solaires, château d'eau | Créent-ils une planification agréable ? |

## 11. Décisions à prendre ensuite

Avant de produire plus de contenu, préciser ces choix :

1. Veux-tu un style moderne réaliste, chaleureux et coloré, ou plutôt sobre et
   industriel ?
2. La station de construction doit-elle être une simple base fonctionnelle ou
   évoluer visuellement en centre-ville au fil des paliers ?
3. Les PNJ doivent-ils transporter physiquement les ressources jusqu'à la
   station, ou la récolte doit-elle être créditée dès qu'ils atteignent le lieu
   de ressource ?
4. Quelle taille de première carte doit encadrer le MVP : très compacte pour
   faciliter les tests, ou déjà assez grande pour créer plusieurs quartiers ?

Les règles précises d'eau et d'électricité ne sont pas une décision à prendre
maintenant ; elles reviendront une fois que les routes et les déplacements
auront été validés en jeu.

Les réponses orienteront l'interface, les contrôles, les sauvegardes et le
contenu à venir, sans remettre en cause le socle du MVP.
