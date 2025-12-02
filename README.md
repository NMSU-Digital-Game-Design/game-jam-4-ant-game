[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/62VukNL6)
# ANT Game: Game Design Document

## Vision Statement
A side-scrolling tug-of-war game where players spawn ant units to push along a single lane, gather food automatically, and overwhelm the enemy colony. The last colony standing wins.

## Gameplay 

### Mechanics
The game is a lane-based tug-of-war similar to Battle Cats. The player earns food automatically over time and can increase the rate by upgrading their base. Using this food, the player spawns different types of ants that march toward the enemy base. Units automatically walk forward, engage any enemy ants, and continue pushing the line.
Core repeated mechanics include:
Spawning units using food


-Upgrading base stats (food production, base health)


-Choosing unit types to counter enemy units


-Timing pushes to overwhelm the enemy colony


This loop repeats until one colony destroys the other.


### Scoring and/or Win / Lose Conditions
The only win condition is destroying the enemy base (the opposing anthill).
You lose if your own base reaches zero health.
Progress is visually tracked by the push of the battle line, the health of both bases, and how quickly you are generating food.

### Controls
-Buttons along the bottom of the screen spawn specific bug units (costing food).


-A separate button upgrades food production.


-Optional buttons: base defense upgrade, special ability.


-No direct movement controls—units march automatically just like Battle Cats.

### Aesthetic
The aesthetic is a 2D side-scrolling, colorful but slightly realistic.

### Desired Player Experience
Players should feel excitement and rising intensity as waves of ants clash. The game should give a sense of building momentum—tiny weak ants at first, then huge swarms later. Players feel strategic when choosing the right unit combos and satisfied when their swarm pushes the line all the way to the enemy anthill. Gameplay should be fast, and addictive.

## Game Characters
Base Characters: Your Anthill – produces ants, can be upgraded over time.

-Enemy Anthill – target to destroy.
-Bug Types

## Story
Two ant colonies are fighting for dominance over a territory rich with resources. Each colony sends waves of ants to overpower the other in a long-term tug-of-war battle. 

## The Game World
Key Locations
-Battle Lane – the main stretch of land where ants march and fight.

-Your Anthill – unit spawning point.

-Enemy Anthill – final goal to destroy.

## Media List
Character Art: different bugs/ants
World Art:
-Background environments (dirt path, forest, rocky terrain)
-Ground textures
-UI elements (unit icons, food meter, upgrade buttons)
-Music and Sound Effects:
-Background music (light, rhythmic, action-paced)
-Ant attack/chomp sounds
-Hit impacts
-Base damage sounds
-Swarm movement sound
-UI button click + spawn effects

