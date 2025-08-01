/mob/living/carbon/human/species/goblinp
	race = /datum/species/goblinp

/datum/species/goblinp
	name = "Goblin"
	id = "goblinp"
	desc = "<b>Goblin</b><br>\
	A vile, cursed race of green skinned fiends with brains as small as their hearts. These creachers only care to obey one nearest to embody the strength and dominance of their progenitor. Slaves to Graggar, be not fooled by their appearance - What they lack in stature they possess in sheer malice." 
	species_traits = list(EYECOLOR,LIPS,STUBBLE)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	possible_ages = ALL_AGES_LIST
	use_skintones = TRUE
	skin_tone_wording = "Skin Color"
	limbs_icon_m = 'icons/mob/species/goblin_male.dmi'
	limbs_icon_f = 'icons/mob/species/goblin_female.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	soundpack_m = /datum/voicepack/male/goblin
	soundpack_f = /datum/voicepack/female/goblinf
	custom_clothes = TRUE
	use_f = TRUE
	clothes_id = "dwarf"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/goblin,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/goblin,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
//		ORGAN_SLOT_TESTICLES = /obj/item/organ/testicles, REDMOON REMOVAL - убираем форсирование половых органов
//		ORGAN_SLOT_PENIS = /obj/item/organ/penis, REDMOON REMOVAL - убираем форсирование половых органов
//		ORGAN_SLOT_BREASTS = /obj/item/organ/breasts, REDMOON REMOVAL - убираем форсирование половых органов
//		ORGAN_SLOT_VAGINA = /obj/item/organ/vagina, REDMOON REMOVAL - убираем форсирование половых органов
		)
	offset_features = list(
		OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,1), OFFSET_WRISTS = list(0,0),\
		OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,-5), OFFSET_HEAD = list(0,-4), \
		OFFSET_FACE = list(0,-5), OFFSET_BELT = list(0,-4), OFFSET_BACK = list(0,-3), \
		OFFSET_NECK = list(0,-4), OFFSET_MOUTH = list(0,-4), OFFSET_PANTS = list(0,0), \
		OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,-3), \
		OFFSET_ID_F = list(0,-4), OFFSET_GLOVES_F = list(0,0), OFFSET_WRISTS_F = list(0,-5), OFFSET_HANDS_F = list(0,-4), \
		OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,-6), OFFSET_HEAD_F = list(0,-5), \
		OFFSET_FACE_F = list(0,-6), OFFSET_BELT_F = list(0,-4), OFFSET_BACK_F = list(0,-4), \
		OFFSET_NECK_F = list(0,-5), OFFSET_MOUTH_F = list(0,-5), OFFSET_BUTT = list(0,-4), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES = list(0,0), OFFSET_UNDIES_F = list(0,0), \
		)
	specstats = list(
		"strength" = -2, 
		"perception" = 0, 
		"intelligence" = -2, 
		"constitution" = 2,
		"endurance" = 1, 
		"speed" = 2,
		"fortune" = 0
		)
	enflamed_icon = "widefire"
	attack_verb = "slash"
	attack_sound = 'sound/blank.ogg'
	miss_sound = 'sound/blank.ogg'
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/organ/testicles/human,
		/datum/customizer/organ/penis/human,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human,
		/datum/customizer/organ/butt/human,
		)
	languages = list(
		/datum/language/common,
		/datum/language/orcish
	)

	stress_examine = TRUE
	stress_desc = span_boldred("A creature of Graggar!")

/datum/species/goblinp/check_roundstart_eligible()
	return TRUE

/datum/species/goblinp/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/goblinp/get_skin_list()
	return list(
		"Teal" = "0d8f68",
		"Viridian" = "0f8a4a",
		"Jade" = "0f8a38",
		"Green" = "0f8a1f",
		"Forest" = "248a0f",
		"Lime" = "3e8a0f",
		"Moss" = "538a0f",
		"Olive" = "6b8a08",
	)

/datum/species/goblinp/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	C.cmode_music = 'sound/music/combat_gronn.ogg'
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/goblinp/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
