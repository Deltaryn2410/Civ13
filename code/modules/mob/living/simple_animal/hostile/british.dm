/mob/living/simple_animal/hostile/british
	name = "Redcoat Soldier"
	desc = "A british soldier."
	icon_state = "britishmelee"
	icon_dead = "britishmelee_dead"
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speak = list("FOR THE KING!","Fucking pirates!")
	speak_emote = list("grumbles", "screams")
	emote_hear = list("curses","grumbles","screams")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = TRUE
	speed = 4
	move_to_delay = 6
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	move_to_delay = 6
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 40
	attacktext = "slashed"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	mob_size = MOB_MEDIUM
	behaviour = "hostile"

	var/corpse = /mob/living/human/corpse/british

	faction = BRITISH


/mob/living/simple_animal/hostile/british/death()
	..()
	if(corpse)
		new corpse (src.loc)
	qdel(src)
	return

/mob/living/simple_animal/hostile/human/british/ranged
	name = "Redcoat Soldier"
	desc = "A british soldier."
	icon_state = "britishranged"
	icon_dead = "britishranged_dead"
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speak = list()
	speak_emote = list()
	emote_hear = list()
	emote_see = list("stares", "cocks musket")
	speak_chance = TRUE
	speed = 6
	stop_automated_movement_when_pulled = 0
	maxHealth = 150
	health = 150
	move_to_delay = 4
	harm_intent_damage = 10
	melee_damage_lower = 35
	melee_damage_upper = 45
	attacktext = "bashed"
	attack_sound = 'sound/weapons/punch3.ogg'
	mob_size = MOB_MEDIUM
	starves = FALSE
	behaviour = "hostile"
	faction = BRITISH
	ranged = TRUE
	rapid = FALSE
	firedelay = 80
	projectiletype = /obj/item/projectile/bullet/rifle/musketball_pistol
	corpse = /mob/living/human/corpse/british
	casingtype = null
	attack_verb = "slashes"

	New()
		..()
		messages["injured"] = list("!!I am injured!","!!I'm hit!!")
		messages["backup"] = list("!!Over here!", "!!Come here!!")
		messages["enemy_sighted"] = list("!!I see one!", "!!HEY YOU!!")
		messages["grenade"] = list("!!GRENADE!")
		if (prob(65))
			gun = new/obj/item/weapon/gun/projectile/flintlock/musketoon(src)
		else
			gun = new/obj/item/weapon/gun/projectile/flintlock/musket(src)

/mob/living/simple_animal/hostile/human/british/ranged/death()
	..()
	if(corpse)
		new corpse (src.loc)
	if(gun)
		gun.forceMove(src.loc)
		qdel(src)
	return

/mob/living/simple_animal/hostile/townmilitia
	name = "Town Militia"
	desc = "A british town militia."
	icon_state = "britishmelee"
	icon_dead = "britishmelee_dead"
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speak = list("FOR THE KING!","Fucking pirates!")
	speak_emote = list("grumbles", "screams")
	emote_hear = list("curses","grumbles","screams")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = TRUE
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	move_to_delay = 6
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 40
	attacktext = "slashed"
	attack_sound = 'sound/weapons/bladeslice.ogg'


	var/corpse = /mob/living/human/corpse/british
	faction = CIVILIAN


/mob/living/simple_animal/hostile/townmilitia/death()
	..()
	if(corpse)
		new corpse (src.loc)
	qdel(src)
	return


/mob/living/simple_animal/hostile/british/voyage
	name = "Redcoat Soldier"
	desc = "A british soldier."
	icon_state = "britishmelee"
	icon_dead = "britishmelee_dead"
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speak = list("FOR THE KING!","Fucking pirates!")
	speak_emote = list("grumbles", "screams")
	emote_hear = list("curses","grumbles","screams")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = TRUE
	speed = 4
	move_to_delay = 6
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	move_to_delay = 6
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 40
	attacktext = "slashed"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	mob_size = MOB_MEDIUM
	behaviour = "hostile"

	corpse = /mob/living/human/corpse/british

	faction = BRITISH


/mob/living/simple_animal/hostile/british/death()
	..()
	if(corpse)
		new corpse (src.loc)
	qdel(src)
	return