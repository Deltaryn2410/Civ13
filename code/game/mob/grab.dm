#define UPGRADE_COOLDOWN	40
#define UPGRADE_KILL_TIMER	100

///Process_Grab()
///Called by client/Move()
///Checks to see if you are grabbing anything and if moving will affect your grab.
/client/proc/Process_Grab()
	for (var/obj/item/weapon/grab/G in list(mob.l_hand, mob.r_hand))
		G.reset_kill_state() //no wandering across the station/asteroid while choking someone

/mob
	var/mouth_covered = FALSE

/obj/item/weapon/grab
	name = "grab"
	icon = 'icons/mob/screen/1713Style.dmi'
	icon_state = "reinforce"
	flags = FALSE
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/human/assailant = null
	var/state = GRAB_PASSIVE
	var/allow_upgrade = TRUE
	var/last_action = FALSE
	var/last_hit_zone = FALSE
	var/force_down //determines if the affecting mob will be pinned to the ground
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = 21
	abstract = TRUE
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()

	loc = user
	user.grab_list = list(src)

	assailant = user
	affecting = victim

	if (affecting.anchored || !assailant.Adjacent(victim))
		qdel(src)
		return

	affecting.grabbed_by += src

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	icon_state = "grabbed"
	hud.name = "reinforce grab"
	hud.master = src

	//check if assailant is grabbed by victim as well
	if (assailant.grabbed_by)
		for (var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if (G.assailant == affecting && G.affecting == assailant)
				G.dancing = TRUE
				G.adjust_position()
				dancing = TRUE
	adjust_position()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw_held()
	if (affecting)
		if (affecting.buckled)
			return null
		if (state >= GRAB_AGGRESSIVE)
			animate(affecting, pixel_x = FALSE, pixel_y = FALSE, 4, TRUE)
			return affecting
	return null

//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if (affecting)
		hud.screen_loc = screen_loc
//		if (assailant.r_hand == src)
//			hud.screen_loc = screen_loc
//		else
//			hud.screen_loc = screen_loc

/obj/item/weapon/grab/process()
	if (gcDestroyed) // GC is trying to delete us, we'll kill our processing so we can cleanly GC
		return PROCESS_KILL

	confirm()
	if (!assailant)
		qdel(src) // Same here, except we're trying to delete ourselves.
		return PROCESS_KILL

	if (assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if (assailant.pulling == affecting)
		assailant.stop_pulling()

	if (state <= GRAB_AGGRESSIVE)
		allow_upgrade = TRUE
		//disallow upgrading if we're grabbing more than one person
		if ((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if (G.affecting != affecting)
				allow_upgrade = FALSE
		if ((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if (G.affecting != affecting)
				allow_upgrade = FALSE

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for (var/obj/item/weapon/grab/G in affecting.grabbed_by)
			if (G == src) continue
			if (G.state >= GRAB_AGGRESSIVE)
				allow_upgrade = FALSE

		if (allow_upgrade)
			if (state < GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce"
			else
				hud.icon_state = "reinforce1"
		else
			hud.icon_state = "!reinforce"

	if (state >= GRAB_AGGRESSIVE)
		affecting.drop_l_hand()
		affecting.drop_r_hand()
		affecting.canmove = FALSE
		if (ishuman(affecting))
			handle_eye_mouth_covering(affecting, assailant, assailant.targeted_organ)

		if (force_down)
			if (affecting.loc != assailant.loc)
				force_down = FALSE
			else
				affecting.Weaken(20)

	if (state >= GRAB_NECK && affecting)
		affecting.Stun(2)
		if (isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if (state >= GRAB_KILL)
		if (ishuman(affecting))
			var/mob/living/human/C = affecting
			C.apply_effect(STUTTER, 5) //It will hamper your voice, being choked and all.
			C.Weaken(5)	//Should keep you down unless you get help.
			C.losebreath = max(C.losebreath + 2, 3)

	adjust_position()

/obj/item/weapon/grab/proc/handle_eye_mouth_covering(mob/living/human/target, mob/user, var/target_zone)
	var/announce = (target_zone != last_hit_zone) //only display messages when switching between different target zones
	last_hit_zone = target_zone

	switch(target_zone)
		if ("mouth")
			if (announce)
				user.visible_message("<span class='warning'>\The [user] covers [target]'s mouth!</span>")
				target.mouth_covered = TRUE
			if (target.silent < 3)
				target.silent = 3
		if ("eyes")
			if (announce)
				assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s eyes!</span>")
			if (affecting.eye_blind < 3)
				affecting.eye_blind = 3

/obj/item/weapon/grab/attack_self()
	return s_click(hud)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if (!affecting)
		return
	if (affecting.buckled)
		animate(affecting, pixel_x = FALSE, pixel_y = FALSE, 4, TRUE, LINEAR_EASING)
		return
	if (affecting.lying && state != GRAB_KILL)
		animate(affecting, pixel_x = FALSE, pixel_y = FALSE, 5, TRUE, LINEAR_EASING)
		if (force_down)
			affecting.set_dir(SOUTH) //face up
		return
	var/shift = FALSE
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if (GRAB_PASSIVE)
			shift = 8
			if (dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if (GRAB_AGGRESSIVE)
			shift = 12
		if (GRAB_NECK, GRAB_UPGRADING)
			shift = -10
			adir = assailant.dir
			affecting.set_dir(assailant.dir)
			affecting.loc = assailant.loc
		if (GRAB_KILL)
			shift = FALSE
			adir = TRUE
			affecting.set_dir(SOUTH) //face up
			affecting.loc = assailant.loc

	switch(adir)
		if (NORTH)
			animate(affecting, pixel_x = FALSE, pixel_y =-shift, 5, TRUE, LINEAR_EASING)
			affecting.layer = 3.9
		if (SOUTH)
			animate(affecting, pixel_x = FALSE, pixel_y = shift, 5, TRUE, LINEAR_EASING)
		if (WEST)
			animate(affecting, pixel_x = shift, pixel_y = FALSE, 5, TRUE, LINEAR_EASING)
		if (EAST)
			animate(affecting, pixel_x =-shift, pixel_y = FALSE, 5, TRUE, LINEAR_EASING)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if (!affecting)
		return
	if (state == GRAB_UPGRADING)
		return
	if (!assailant.canClick())
		return
	if (world.time < (last_action + UPGRADE_COOLDOWN))
		return
	if (!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_action = world.time

	if (state < GRAB_AGGRESSIVE)
		if (!allow_upgrade)
			return
		if (!affecting.lying)
			assailant.visible_message("<span class='warning'>[assailant] хватает [affecting] в сильный захват!</span>")
		else
			assailant.visible_message("<span class='warning'>[assailant] pins [affecting] down to the ground (now hands)!</span>")
			apply_pinning(affecting, assailant)

		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
		hud.icon_state = "reinforce1"
	else if (state < GRAB_NECK)
		assailant.visible_message("<span class='warning'>[assailant] схватил [affecting] за горло!</span>")
		state = GRAB_NECK
		icon_state = "grabbed+1"
		assailant.set_dir(get_dir(assailant, affecting))
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])([affecting.stat])</font>"
		msg_admin_attack("[key_name(assailant)] grabbed the neck of [key_name(affecting)]")
		hud.icon_state = "kill"
		hud.name = "kill"
		affecting.Stun(7) //7 ticks of ensured grab
	else if (state < GRAB_UPGRADING)
		assailant.visible_message("<span class='danger'>[assailant] начинает душить [affecting]!</span>")
		hud.icon_state = "kill1"

		state = GRAB_KILL
		assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])([affecting.stat])</font>"
		msg_admin_attack("[key_name(assailant)] strangled (kill intent) [key_name(affecting)]")

		affecting.setClickCooldown(10)
		affecting.set_dir(WEST)
		if (ishuman(affecting))
			var/mob/living/human/C = affecting
			C.losebreath += 1
	adjust_position()

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if (!assailant || !affecting)
		qdel(src)
		return FALSE

	if (affecting)
		if (!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return FALSE

	return TRUE

/obj/item/weapon/grab/attack(mob/M, mob/living/user)
	if (!affecting)
		return
	if (world.time < (last_action + 20))
		return

	last_action = world.time
	reset_kill_state() //using special grab moves will interrupt choking them

	//clicking on the victim while grabbing them
	if (M == affecting)
		if (ishuman(affecting))
			var/mob/living/human/H = affecting
			var/hit_zone = assailant.targeted_organ
			flick(hud.icon_state, hud)
			switch(assailant.a_intent)
				if (I_HELP)
					if (force_down)
						assailant << "<span class='warning'>You are no longer pinning [affecting] to the ground.</span>"
						force_down = FALSE
						return
					if(state >= GRAB_AGGRESSIVE)
						H.apply_pressure(assailant, hit_zone)
					else
						inspect_organ(affecting, assailant, hit_zone)

				if (I_GRAB)
					jointlock(affecting, assailant, hit_zone)

				if (I_HARM)
					if (hit_zone == "eyes")
						attack_eye(affecting, assailant)
					else if (hit_zone == "head")
						headbut(affecting, assailant)
					else
						dislocate(affecting, assailant, hit_zone)

				if (I_DISARM)
					pin_down(affecting, assailant)

	//clicking on yourself while grabbing them
	if (M == assailant && state >= GRAB_AGGRESSIVE)
		devour(affecting, assailant)

/obj/item/weapon/grab/dropped()
	if (ismob(loc))
		var/mob/M = loc
		M.mouth_covered = FALSE
		M.grab_list = list()
		M.canmove = TRUE
	loc = null
	if (!destroying)
		qdel(src)

/obj/item/weapon/grab/proc/reset_kill_state()
	if (state == GRAB_KILL)
		if (assailant)
			assailant.visible_message("<span class='warning'>[assailant] lost \his tight grip on [affecting]'s neck!</span>")
		hud.icon_state = "kill"
		state = GRAB_NECK

/obj/item/weapon/grab
	var/destroying = FALSE

/obj/item/weapon/grab/Destroy()

	// I don't even think this works since its loc is already == null but whatever - Kachnov
	if (loc)
		if (ismob(loc))
			var/mob/M = loc
			M.grab_list = list()
			M.canmove = TRUE
	if (affecting)
		animate(affecting, pixel_x = FALSE, pixel_y = FALSE, 4, TRUE, LINEAR_EASING)
		affecting.layer = 4
		affecting.grabbed_by -= src
		affecting = null
	if (assailant)
		if (assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	hud = null
	destroying = TRUE // stops us calling qdel(src) on dropped()
	..()
