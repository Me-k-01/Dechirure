# Dechirure
Ce projet a été réalisé dans le cadre de l'UE Modélisation et animation sur Processing.
Dans ce projet nous simulons les déchirure de tissu en se servant d'un modèle de masses et de ressorts. 
Une correction est appliquée après l'intégration des forces afin de minimiser les instabilités du système; en limitant l'extensibilité des ressorts sur un pas de temps donné.
3 scènes sont prédéfinies dans le fichier preset.json.
L'utilisateur peut interagir avec les tissus avec sa souris et déplacer la caméra. Une procédure de découpage des ressorts permet lorsqu'il est trop étendu de reproduire le phénomène de déchirure du tissus.

[demo](./Img/demo.png "Démo de déchirure sur la scène 1")

> Lien de la vidéo de présentation du projet : 
[https://www.youtube.com/watch?v=9F-dFGtQmTc](https://www.youtube.com/watch?v=9F-dFGtQmTc)

> Lien du dépot Git : 
[https://github.com/Me-k-01?tab=repositories](https://github.com/Me-k-01?tab=repositories)

## Contrôle
- La correction des ressorts peut être activée et désactivée en appuyant sur la touche "c" du clavier.
- La simulation peut être mise en pause en appuyant sur la touche "p".
- Les touches "1", "2" et "3" du clavier permettent de changer de scène.
- On peut visualiser les ressorts en appuyant sur la touche "t" du clavier.
- On peut stopper les déchirures automatiques avec la touche "b".
- En appuyant sur la touche "s" du clavier, une déchirure parfaitement droite peut être appliqué sur les scènes 2 et 3.
