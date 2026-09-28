## Une seule petite ville/carte 2D

Avec quelques emplacements où construire.

1. **Une ressource de départ : le bois.** Le joueur commence par exemple avec 2 PNJ. Il peut assigner un PNJ à un arbre, qui produit automatiquement `+1 bois / 3 secondes`.
2. **Un premier bâtiment : la scierie.** Exemple : 20 bois pour la construire. Une fois construite, elle améliore ou automatise la production de bois.
3. **Une deuxième ressource : la pierre.** La scierie ou une première amélioration permet de débloquer une carrière. Les PNJ peuvent alors produire de la pierre.
4. **Quelques bâtiments seulement**, par exemple Maison → augmente le nombre de PNJ ; Scierie → bois ; Carrière → pierre ; Entrepôt → augmente la capacité de stockage.
5. **Une progression exponentielle légère.** Au début tu produis très lentement, puis tes bâtiments prennent progressivement le relais. Le joueur ressent : *« au début je gérais 2 personnes, maintenant ma petite ville tourne presque toute seule »*.

Et surtout, **je ne mettrais pas** dans le MVP : combats, météo, saisons, arbre technologique complexe, dizaines de ressources, habitants avec faim/soif/bonheur, commerce, multijoueur, quêtes complexes ou grande carte. Tout ça pourra venir après.

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

Je pense même que ton MVP devrait avoir un objectif très simple du genre **« construire l'Hôtel de Ville niveau 2 »**. Une partie MVP pourrait durer seulement **15–30 minutes**. Si ces 20 minutes sont plaisantes avec seulement 2 ressources et 4 bâtiments, tu tiens une base intéressante.

Et pour le développement, je construirais les systèmes dans cet ordre : **ressources → PNJ → assignation des PNJ → production automatique → bâtiments → améliorations → sauvegarde → progression hors-ligne**. La sauvegarde et l'idle hors-ligne arrivent relativement tard : au départ, il faut surtout vérifier que la boucle est amusante lorsque le jeu est ouvert.

Si tu veux, on peut maintenant **concevoir ton MVP précisément**, avec les ressources, les 4–6 bâtiments, leurs coûts, leurs productions et les 20 premières minutes de progression.
