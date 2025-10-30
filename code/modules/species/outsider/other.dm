/singleton/species/other
	name = "The Other"
	name_plural = "Others"
	description = "A cosmic entity from beyond reality, existing between dimensions. Its form shifts and phases, defying mortal comprehension."
	
	icobase = 'icons/mob/human_races/species/other/body.dmi'
	deform = 'icons/mob/human_races/species/other/body.dmi'
	preview_icon = 'icons/mob/human_races/species/other/body.dmi'
	
	meat_type = null
	bone_material = null
	skin_material = null
	
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/sharp)
	darksight_range = 10
	darksight_tint = DARKTINT_GOOD
	siemens_coefficient = 0.5
	
	blood_color = "#9900ff"
	flesh_color = "#330066"
	
	remains_type = /obj/decal/cleanable/ash
	death_message = "phases out of reality, leaving only cosmic echoes..."
	
	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_EMBED
	spawn_flags = SPECIES_IS_RESTRICTED
	
	// Cosmic entity traits
	brute_mod = 0.8
	burn_mod = 0.8
	toxins_mod = 0.5
	radiation_mod = 0.3
	
	// Phase-like properties
	pass_flags = PASSTABLE
	
	// Breathing
	breath_type = null
	poison_type = null
	
/singleton/species/other/handle_environment_special(mob/living/carbon/human/H)
	if(H.InStasis() || H.is_dead() || H.isSynthetic())
		return
	
	// The Other slowly regenerates in darkness
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
	
	if(light_amount < 2) // In darkness, slowly heal
		H.heal_overall_damage(0.5, 0.5)
	
	// Cosmic energy sustains The Other
	if(H.nutrition < 400)
		H.nutrition = min(H.nutrition + 2, 400)

/singleton/species/other/get_bodytype(mob/living/carbon/human/H)
	return SPECIES_HUMAN // Use human bodytype for equipment compatibility