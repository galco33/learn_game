## Une seule petite ville moderne en vue isométrique

Construite librement sur une grille de cases. Le joueur commence avec une
station de construction, quelques arbres et rochers. Il peut choisir où poser
ses bâtiments et tracer des routes ; les PNJ marchent d'abord sur l'herbe, mais
les routes accélèrent ensuite leurs trajets vers les récoltes et les bâtiments.

1. **Une ressource de départ : le bois.** Le joueur commence avec une station de construction, 2 PNJ et quelques arbres. Il peut assigner un PNJ à un arbre, qui produit automatiquement `+1 bois / 3 secondes`.
2. **Un premier bâtiment : la scierie.** Exemple : 20 bois pour la construire. Une fois construite, elle améliore ou automatise la production de bois.
3. **Une deuxième ressource : la pierre.** La scierie ou une première amélioration permet de débloquer une carrière. Les PNJ peuvent alors produire de la pierre.
4. **Quelques bâtiments seulement**, par exemple Maison → augmente le nombre de PNJ ; Scierie → bois ; Carrière → pierre ; Entrepôt → augmente la capacité de stockage. Le joueur les place sur des cases libres, puis les organise avec des routes qui accélèrent les PNJ.
5. **Une progression exponentielle légère.** Au début tu produis très lentement, puis tes bâtiments prennent progressivement le relais. Le joueur ressent : *« au début je gérais 2 personnes, maintenant ma petite ville tourne presque toute seule »*.

Et surtout, **je ne mettrais pas** dans le MVP : combats, météo, saisons, arbre technologique complexe, dizaines de ressources, habitants avec faim/soif/bonheur, commerce, multijoueur, quêtes complexes, grande carte, contraintes d'eau et contraintes d'électricité. Les routes préparent ces futurs réseaux, mais les centrales, poteaux, lignes et conduites arriveront après la validation de la boucle de base. Tout ça pourra venir après.

### Exemple de 10 premières minutes

Tu commences avec :

**👤👤 2 habitants — 🪵 0 bois**

Tu assignes tes deux habitants à la récolte.

→ +2 🪵 toutes les quelques secondes  
→ 20 🪵 : construction d'une **scierie**  
→ la scierie automatise/améliore le bois  
→ 50 🪵 : construction d'une **maison**  
→ +1 👤  
→ tu assignes ce nouveau PNJ à la **pierre**  
→ 🪨 production de pierre  
→ bois + pierre permettent un nouveau bâtiment  
→ etc.

C'est déjà suffisant pour découvrir quelque chose de très important : **est-ce satisfaisant de regarder sa petite ville progressivement s'automatiser ?**

Je pense même que ton MVP devrait avoir un premier jalon très simple du genre **« améliorer la station de construction au niveau 2 »**. Il ne termine pas la partie : la ville est conçue pour être conservée et grandir sur plusieurs jours. La première session peut durer **15–30 minutes**. Si ces 20 minutes sont plaisantes avec seulement 2 ressources et 4 bâtiments, tu tiens une base intéressante.

Et pour le développement, je construirais les systèmes dans cet ordre : **grille → station de construction → ressources → PNJ et déplacements → routes et bonus de vitesse → assignation des PNJ → production automatique → bâtiments → améliorations → sauvegarde → progression hors-ligne**. La sauvegarde devient nécessaire dès que le premier jalon est jouable, car la ville doit persister plusieurs jours.

Si tu veux, on peut maintenant **concevoir ton MVP précisément**, avec les ressources, les 4–6 bâtiments, leurs coûts, leurs productions et les 20 premières minutes de progression.
