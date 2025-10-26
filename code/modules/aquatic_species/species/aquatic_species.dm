/singleton/species/aquatic_mech
	name = "Aquatic"
	name_plural = "Aquatics"
	description = "A fish-like aquatic species housed in a robotic water-filled suit for survival in air environments."

	// Icon paths
	icobase = 'icons/mob/human_races/species/human/body.dmi' // once art is acquired, replace these with paths from aquatic_species.dmi
	deform = 'icons/mob/human_races/species/human/deformed_body.dmi'
	preview_icon = 'icons/mob/human_races/species/human/preview.dmi'

	// Environmental requirements
	breath_type = null // suit handles breathing
	breath_pressure = 0
	cold_level_1 = 200
	cold_level_2 = 150
	cold_level_3 = 100
	heat_level_1 = 400
	heat_level_2 = 450
	heat_level_3 = 600

	// Minimal organs
	has_organ = list(
		BP_BRAIN = /obj/item/organ/internal/brain,
		BP_EYES = /obj/item/organ/internal/eyes
	)

	// Special flags
	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_PAIN
	appearance_flags = SPECIES_APPEARANCE_HAS_SKIN_COLOR
	spawn_flags = SPECIES_CAN_JOIN

	// Combat stats
	total_health = 150
	brute_mod = 1.2
	burn_mod = 1.5

	// Movement
	slowdown = 0.5



/singleton/species/aquatic_mech/proc/handle_environment_special_aquatic(mob/living/carbon/human/H)
	if(!has_valid_suit(H))
		H.take_organ_damage(10)
		H.visible_message(
			SPAN_DANGER("[H]'s aquatic skin begins to dry out!"),
			SPAN_DANGER("You feel your skin drying out! You need your suit!")
		)
		return FALSE
	return TRUE

/singleton/species/aquatic_mech/proc/has_valid_suit(mob/living/carbon/human/H)
	if(!H.wear_suit)
		return FALSE
	return istype(H.wear_suit, /obj/item/clothing/suit/aquatic_mech)
