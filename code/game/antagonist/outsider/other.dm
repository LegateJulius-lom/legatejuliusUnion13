GLOBAL_TYPED_NEW(others, /datum/antagonist/other)

/datum/antagonist/other
	id = MODE_OTHER
	role_text = ANTAG_OTHER
	role_text_plural = ANTAG_OTHER + "s"
	landmark_id = "other"
	welcome_text = "You are The Other, a cosmic entity from beyond the veil of reality. Your presence alone disturbs the fabric of space-time. \
		Use your abilities to spread fear and chaos among the crew. You can speak to mortals through your Speak ability, \
		phase through walls, and unleash devastating sonic attacks that shatter lights and deafen those nearby."
	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_VOTABLE | ANTAG_SET_APPEARANCE
	antaghud_indicator = "hudwizard"

	hard_cap = 1
	hard_cap_round = 2
	initial_spawn_req = 1
	initial_spawn_target = 1
	min_player_age = 21

	faction = "other"
	no_prior_faction = TRUE

/datum/antagonist/other/create_objectives(datum/mind/other_mind)
	if(!..())
		return

	// The Other has simple objectives - spread chaos and fear
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = other_mind
	other_mind.objectives |= survive_objective

	var/datum/objective/other_chaos/chaos_objective = new
	chaos_objective.owner = other_mind
	other_mind.objectives |= chaos_objective

	return

/datum/objective/other_chaos
	explanation_text = "Spread fear and chaos among the crew using your otherworldly abilities."

/datum/objective/other_chaos/check_completion()
	return TRUE // Always considered successful if they survive

/datum/antagonist/other/update_antag_mob(datum/mind/other_mind)
	..()
	other_mind.StoreMemory("<B>Remember:</B> You are a cosmic entity. Use your abilities to spread fear and chaos.", /singleton/memory_options/system)
	
	// Give The Other a mysterious name
	var/list/other_names = list("The Void Walker", "The Shadow Between", "The Whisper in Dark", "The Unseen Presence", 
		"The Echo of Nothing", "The Silent Watcher", "The Darkness That Speaks", "The Other")
	other_mind.current.real_name = pick(other_names)
	other_mind.current.SetName(other_mind.current.real_name)

/datum/antagonist/other/equip(mob/living/carbon/human/other_mob)
	if(!..())
		return 0

	// Give The Other a dark, otherworldly appearance
	other_mob.set_species("Human") // Base it on human but we'll modify appearance
	
	// Dark clothing
	other_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(other_mob), slot_w_uniform)
	other_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(other_mob), slot_shoes)
	other_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/hooded/wintercoat/captain(other_mob), slot_wear_suit)
	other_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(other_mob), slot_gloves)

	// Add abilities to The Other
	add_other_abilities(other_mob)

	return 1

/datum/antagonist/other/proc/add_other_abilities(mob/living/carbon/human/other_mob)
	// Add The Other's abilities
	other_mob.verbs += /mob/living/carbon/human/proc/other_speak
	other_mob.verbs += /mob/living/carbon/human/proc/other_sonic_disruption
	other_mob.verbs += /mob/living/carbon/human/proc/other_phase

/datum/antagonist/other/remove_antagonist(datum/mind/player, show_message, implanted)
	if(!..())
		return 0
	
	var/mob/living/carbon/human/other_mob = player.current
	if(istype(other_mob))
		// Remove The Other's abilities
		other_mob.verbs -= /mob/living/carbon/human/proc/other_speak
		other_mob.verbs -= /mob/living/carbon/human/proc/other_sonic_disruption
		other_mob.verbs -= /mob/living/carbon/human/proc/other_phase
	
	return 1

// Helper function to check if someone is The Other
/proc/isother(mob/subject)
	var/datum/mind/mind = subject
	if (ismob(mind))
		mind = subject.mind
	return istype(mind) && (mind in GLOB.others?.current_antagonists)

// Speak ability - allows The Other to narrate to players
/mob/living/carbon/human/proc/other_speak()
	set name = "Speak"
	set category = "The Other"
	set desc = "Speak directly to the minds of nearby mortals."

	if(!isother(src))
		return

	var/message = input("What do you wish to whisper into their minds?", "Cosmic Narration") as text|null
	if(!message)
		return

	message = sanitize(message)
	if(!message)
		return

	// Send the message to nearby players
	var/range = 7
	var/formatted_message = "<span class='cult'><i><b>A voice echoes in your mind...</b></i></span>"
	formatted_message += "<br><span class='cult'><i>\"[message]\"</i></span>"

	for(var/mob/living/M in range(range, src))
		if(M == src)
			continue
		if(M.client)
			to_chat(M, formatted_message)
			// Add a subtle sound effect
			M.playsound_local(M, 'sound/effects/ghost.ogg', 25, 1)

	// Show what The Other said to them
	to_chat(src, "<span class='notice'>You whisper into the minds of nearby mortals: \"[message]\"</span>")

// Sonic Disruption ability - deafens players and shatters lights
/mob/living/carbon/human/proc/other_sonic_disruption()
	set name = "Sonic Disruption"
	set category = "The Other"
	set desc = "Unleash a devastating sonic attack that deafens mortals and shatters lights."

	if(!isother(src))
		return

	// Check cooldown
	if(world.time < (src.last_sonic_disruption + 30 SECONDS))
		to_chat(src, "<span class='warning'>The cosmic energies are still recovering... ([round((src.last_sonic_disruption + 30 SECONDS - world.time)/10)] seconds remaining)</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You cannot unleash your power here.</span>")
		return

	src.last_sonic_disruption = world.time

	visible_message("<span class='danger'>[src] raises their hands as reality itself seems to vibrate!</span>")
	playsound(src, 'sound/effects/phasein.ogg', 100, 1)

	var/range = 5
	var/list/affected = list()

	// Affect nearby mobs
	for(var/mob/living/M in range(range, src))
		if(M == src)
			continue
		
		if(iscarbon(M))
			to_chat(M, "<span class='danger'>A terrible sonic wave washes over you! Your ears ring with otherworldly noise!</span>")
			M.adjustEarDamage(0, 45) // Deafen them
			M.Stun(2) // Brief stun from the overwhelming sound
			affected += M
		
		if(issilicon(M))
			to_chat(M, "<span class='warning'>ERROR: Audio sensors overloaded. Recalibrating...</span>")
			M.Weaken(rand(3, 6))
			affected += M

	// Shatter lights
	for(var/obj/machinery/light/L in range(range, src))
		if(L.status == LIGHT_OK)
			L.broken()
			new /obj/item/material/shard(get_turf(L))

	// Turn off flashlights
	for(var/obj/item/device/flashlight/F in range(range, src))
		if(F.on)
			F.on = FALSE
			F.set_light(0)
			F.update_icon()

	to_chat(src, "<span class='notice'>You unleash your cosmic power, disrupting the material realm around you.</span>")
	
	if(length(affected))
		admin_attack_log(src, affected, "Used The Other's Sonic Disruption ability")

// Phase ability - allows The Other to phase through walls
/mob/living/carbon/human/proc/other_phase()
	set name = "Phase"
	set category = "The Other"
	set desc = "Phase through the material realm, allowing passage through walls."

	if(!isother(src))
		return

	// Check cooldown
	if(world.time < (src.last_phase + 15 SECONDS))
		to_chat(src, "<span class='warning'>You cannot phase again so soon... ([round((src.last_phase + 15 SECONDS - world.time)/10)] seconds remaining)</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You cannot phase from here.</span>")
		return

	src.last_phase = world.time

	// Create a temporary phase effect similar to ethereal jaunt but shorter
	var/obj/other_phase_holder/phase_holder = new(get_turf(src))
	
	visible_message("<span class='notice'>[src] flickers and becomes translucent!</span>")
	to_chat(src, "<span class='notice'>You phase out of the material realm...</span>")
	
	playsound(src, 'sound/effects/phasein.ogg', 50, 1)
	
	// Move the player into the phase holder
	src.forceMove(phase_holder)
	
	// Set a timer to bring them back
	addtimer(new Callback(src, PROC_REF(end_phase), phase_holder), 8 SECONDS)

/mob/living/carbon/human/proc/end_phase(obj/other_phase_holder/phase_holder)
	if(!phase_holder || loc != phase_holder)
		return
	
	var/turf/exit_turf = phase_holder.last_valid_turf
	if(!exit_turf || !src.forceMove(exit_turf))
		// Try to find a nearby valid turf
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/turf/T = get_step(phase_holder.last_valid_turf, direction)
			if(T && src.forceMove(T))
				break
	
	visible_message("<span class='notice'>[src] materializes back into reality!</span>")
	to_chat(src, "<span class='notice'>You return to the material realm.</span>")
	playsound(src, 'sound/effects/phasein.ogg', 50, 1)
	
	qdel(phase_holder)

// Phase holder object - similar to ethereal jaunt but simpler
/obj/other_phase_holder
	name = "phase space"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	var/turf/last_valid_turf
	var/can_move = TRUE

/obj/other_phase_holder/New(location)
	..()
	last_valid_turf = get_turf(location)

/obj/other_phase_holder/Destroy()
	// Eject contents if deleted somehow
	for(var/atom/movable/AM in src)
		AM.dropInto(loc)
	return ..()

/obj/other_phase_holder/relaymove(mob/user, direction)
	if(!can_move)
		return
	
	var/turf/newLoc = get_step(src, direction)
	if(!newLoc)
		to_chat(user, "<span class='warning'>You cannot phase that way.</span>")
		return
	
	forceMove(newLoc)
	var/turf/T = get_turf(loc)
	if(!T.contains_dense_objects())
		last_valid_turf = T
	
	can_move = FALSE
	addtimer(new Callback(src, PROC_REF(allow_move)), 3)

/obj/other_phase_holder/proc/allow_move()
	can_move = TRUE

// Add variables to track cooldowns
/mob/living/carbon/human
	var/last_sonic_disruption = 0
	var/last_phase = 0