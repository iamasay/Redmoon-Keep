//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHEStype_butt
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 15 // 10 seconds
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	grind_results = list(/datum/reagent/phosphorus = 2)

/obj/item/match/process()
	smoketime--
	if(smoketime < 1)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(added, maxstacks)
	matchignite()

/obj/item/match/spark_act()
	fire_act()

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		testing("ignis1")
		playsound(src, "sound/items/match.ogg", 100, FALSE)
		lit = TRUE
		icon_state = "match_lit"
		testing("ignis2")
		damtype = "fire"
		force = 3
		set_light(3)
		hitsound = list('sound/blank.ogg')
		name = "lit [initial(name)]"
		desc = ""
		attack_verb = list("burnt","singed")
		START_PROCESSING(SSobj, src)

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		set_light(0)
		damtype = "brute"
		force = initial(force)
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt [initial(name)]"
		desc = ""
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)

/obj/item/match/extinguish()
	matchburnout()

/obj/item/match/dropped(mob/user)
	matchburnout()
	. = ..()

/obj/item/match/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(lit && !burnt)
		A.spark_act()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return
//	if(lit && M.IgniteMob())
//		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
//		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, span_warning("[cig] is already lit!"))
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light(span_notice("[user] holds [src] out for [M], and lights [cig]."))
	else
		..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(SLOT_MOUTH)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/get_temperature()
	return lit * heat

/obj/item/match/firebrand
	name = "firebrand"
	desc = ""
	smoketime = 20 //40 seconds
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/match/firebrand/Initialize()
	. = ..()
	matchignite()

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = ""
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	slot_flags = ITEM_SLOT_MOUTH
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/mouth_items.dmi'
	icon = 'icons/roguetown/items/lighting.dmi'
	heat = 1000
	spitoutmouth = FALSE

	grid_width = 32
	grid_height = 32

	var/dragtime = 100
	var/nextdragtime = 0
	var/lit = FALSE
	var/starts_lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	var/smoketime = 180 // 1 is 2 seconds, so a single cigarette will last 6 minutes.
	var/chem_volume = 30
	var/smoke_all = TRUE /// Should we smoke all of the chems in the cig before it runs out. Splits each puff to take a portion of the overall chems so by the end you'll always have consumed all of the chems inside.
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is huffing [src] as quickly as [user.p_they()] can! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer."))
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/Initialize()
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff,90,list(BODY_ZONE_PRECISE_MOUTH),list(SLOT_MOUTH))//90% to knock off when wearing a mask

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user, params)
	if(!lit && smoketime > 0)
		var/lighting_text = W.ignition_effect(src, user)
		if(lighting_text)
			light(lighting_text)
	else
		return ..()

/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)
	. = ..()
//	if(!proximity || lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
//		return
//	if(istype(glass))	//you can dip cigarettes into beakers
//		if(glass.reagents.trans_to(src, chem_volume, transfered_by = user))	//if reagents were transfered, show the message
//			to_chat(user, span_notice("I dip \the [src] into \the [glass]."))
//		else			//if not, either the beaker was empty, or the cigarette was full
//			if(!glass.reagents.total_volume)
//				to_chat(user, span_warning("[glass] is empty!"))
//			else
//				to_chat(user, span_warning("[src] is full!"))


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return
	if(smoketime <= 0)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		item_state = icon_on
		return

	lit = TRUE
//	name = "lit [name]"
	attack_verb = list("burnt", "singed")
	hitsound = list('sound/blank.ogg')
	damtype = "fire"
	force = 4
	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	// allowing reagents to react after being lit
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	//can't think of any other way to update the overlays :<
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_mouth()
		M.update_inv_hands()
		playsound(loc, 'sound/items/light_cig.ogg', 100, TRUE)

/obj/item/clothing/mask/cigarette/extinguish()
	if(!lit)
		return
	attack_verb = null
	hitsound = null
	damtype = BRUTE
	force = 0
	icon_state = icon_off
	item_state = icon_off
	STOP_PROCESSING(SSobj, src)
	ENABLE_BITFIELD(reagents.flags, NO_REACT)
	lit = FALSE
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, span_notice("My [name] goes out."))
		M.update_inv_mouth()
		M.update_inv_hands()

/obj/item/clothing/mask/cigarette/proc/handle_reagents()
	if(reagents.total_volume)
		var/to_smoke = REAGENTS_METABOLISM
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.mouth) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1)
				/*
				 * Given the amount of time the cig will last, and how often we take a hit, find the number
				 * of chems to give them each time so they'll have smoked it all by the end.
				 */
				if (smoke_all)
					if(!smoketime)
						to_smoke = reagents.total_volume
					else
						to_smoke = reagents.total_volume/smoketime

				reagents.reaction(C, INGEST, fraction)
				if(!reagents.trans_to(C, to_smoke))
					reagents.remove_any(to_smoke)
				return
		reagents.remove_any(to_smoke)

/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
//	if(isliving(loc))
//		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/M = loc
			M.dropItemToGround(src, silent = TRUE)
			var/obj/item/butt = new type_butt(get_turf(M))
			M.equip_to_slot_if_possible(butt, SLOT_MOUTH, bypass_equip_delay_self = TRUE)
		else
			new type_butt(location)
		qdel(src)
		return
	open_flame()
	if((reagents && reagents.total_volume) && (nextdragtime <= world.time))
		nextdragtime = world.time + dragtime
		handle_reagents()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message(span_notice("[user] calmly drops and treads on \the [src], putting it out instantly."))
		new type_butt(user.loc)
		new /obj/item/ash(user.loc)
		qdel(src)
	. = ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()
	if(M.on_fire && !lit)
		light(span_notice("[user] lights [src] with [M]'s burning body. What a cold-blooded badass."))
		return
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, span_warning("The [cig.name] is already lit!"))
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light(span_notice("[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name]."))
	else
		return ..()

/obj/item/clothing/mask/cigarette/fire_act(added, maxstacks)
	light()

/obj/item/clothing/mask/cigarette/spark_act()
	fire_act()

/obj/item/clothing/mask/cigarette/get_temperature()
	return lit * heat

// Cigarette brands.

/obj/item/clothing/mask/cigarette/rollie
	name = "zig"
	desc = ""
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/zig
	throw_speed = 0.5
	item_state = "spliffoff"
	smoketime = 120 // four minutes
	chem_volume = 50
	list_reagents = null
	muteinmouth = FALSE

/obj/item/clothing/mask/cigarette/rollie/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 30)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/space_drugs = 30)

/obj/item/clothing/mask/cigarette/rollie/mindbreaker
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 35, /datum/reagent/toxin/lipolicide = 15)

/obj/item/cigbutt
	name = "cigarette butt"
	desc = ""
	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)
	slot_flags = ITEM_SLOT_MOUTH
	spitoutmouth = TRUE

/obj/item/cigbutt/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/cigbutt/zig
	name = "roach"
	desc = "Seems to be a roach of some spent zig"
	icon_state = "roach"
	muteinmouth = FALSE

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "pipe"
	desc = ""
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 120
	chem_volume = 100
	list_reagents = null
	var/packeditem = 0
	slot_flags = ITEM_SLOT_MOUTH
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/mouth_items.dmi'
	icon = 'icons/roguetown/items/lighting.dmi'
	muteinmouth = FALSE

/obj/item/clothing/mask/cigarette/pipe/westman
	name = "westman pipe"
	desc = ""
	icon_state = "longpipeoff"
	item_state = "longpipeoff"
	icon_on = "longpipeon"  //Note - these are in masks.dmi
	icon_off = "longpipeoff"

/obj/item/clothing/mask/cigarette/pipe/crafted/Initialize()
	. = ..()
	if(prob(50))
		name = "westman pipe"
		icon_state = "longpipeoff"
		item_state = "longpipeoff"
		icon_on = "longpipeon"
		icon_off = "longpipeoff"

/obj/item/clothing/mask/cigarette/pipe/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/pipe/process()
	if(smoketime <= 0 || !packeditem)
		packeditem = 0
		smoketime = 0
		STOP_PROCESSING(SSobj, src)
		return
	smoketime = max(smoketime -1, 0)
	if(smoketime <= 0)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, span_notice("The [name] goes out."))
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_mouth()
			packeditem = 0
//			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/G = O
		if(!packeditem)
			if(G.dry == 1)
				to_chat(user, span_notice("I stuff [O] into [src]."))
				smoketime = initial(smoketime)
				packeditem = 1
//				name = "[O.name]-packed [initial(name)]"
				if(G.pipe_reagents?.len)
					reagents.add_reagent_list(G.pipe_reagents)
//					O.reagents.trans_to(src, O.reagents.total_volume, transfered_by = user)
				qdel(O)
			else
				to_chat(user, span_warning("It has to be dried first!"))
		else
			to_chat(user, span_warning("It is already packed!"))
	else if(istype(O, /obj/item/reagent_containers/powder/ozium))
		var/obj/item/reagent_containers/powder/ozium/G = O
		if(!packeditem)
			to_chat(user, span_notice("I stuff [O] into [src]."))
			smoketime = initial(smoketime)
			packeditem = 1
			if(G.list_reagents?.len)
				reagents.add_reagent_list(G.list_reagents)
			qdel(O)
		else
			to_chat(user, span_warning("It is already packed!"))
	else
		var/lighting_text = O.ignition_effect(src,user)
		if(lighting_text)
			if(smoketime > 0)
				light(lighting_text)
			else
				to_chat(user, span_warning("There is nothing to smoke!"))
		else
			return ..()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message(span_notice("[user] puts out [src]."), span_notice("I put out [src]."))
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(!lit && smoketime > 0)
		smoketime = 0
		to_chat(user, span_notice("I empty [src] onto [location]."))
		new /obj/item/ash(location)
		packeditem = 0
		reagents.clear_reagents()
//		name = "empty [initial(name)]"
	return

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = ""
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 0


/////////
//ZIPPO//
/////////
/obj/item/lighter
	name = "\improper Zippo lighter"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	var/lit = 0
	var/fancy = TRUE
	var/overlay_state
	var/overlay_list = list(
		"plain",
		"dame",
		"thirteen",
		"snake"
		)
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/fuel/oil = 5)

/obj/item/lighter/Initialize()
	. = ..()
	if(!overlay_state)
		overlay_state = pick(overlay_list)
	update_icon()

/obj/item/lighter/suicide_act(mob/living/carbon/user)
	if (lit)
		user.visible_message(span_suicide("[user] begins holding \the [src]'s flame up to [user.p_their()] face! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/blank.ogg', 50, TRUE)
		return FIRELOSS
	else
		user.visible_message(span_suicide("[user] begins whacking [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

/obj/item/lighter/update_icon()
	cut_overlays()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	add_overlay(lighter_overlay)

/obj/item/lighter/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = span_rose("With a single flick of [user.p_their()] wrist, [user] smoothly lights [A] with [src]. Damn [user.p_theyre()] cool.")

/obj/item/lighter/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	if(lit)
		force = 5
		damtype = "fire"
		hitsound = list('sound/blank.ogg')
		attack_verb = list("burnt", "singed")
		START_PROCESSING(SSobj, src)
	else
		hitsound = list("swing_hit")
		force = 0
		attack_verb = null //human_defense.dm takes care of it
		STOP_PROCESSING(SSobj, src)
	set_light_on(lit)
	update_icon()

/obj/item/lighter/extinguish()
	set_lit(FALSE)

/obj/item/lighter/attack_self(mob/living/user)
	if(user.is_holding(src))
		if(!lit)
			set_lit(TRUE)
			if(fancy)
				user.visible_message(span_notice("Without even breaking stride, [user] flips open and lights [src] in one smooth movement."), span_notice("Without even breaking stride, you flip open and light [src] in one smooth movement."))
			else
				var/prot = FALSE
				var/mob/living/carbon/human/H = user

				if(istype(H) && H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(G.max_heat_protection_temperature)
						prot = (G.max_heat_protection_temperature > 360)
				else
					prot = TRUE

				if(prot || prob(75))
					user.visible_message(span_notice("After a few attempts, [user] manages to light [src]."), span_notice("After a few attempts, you manage to light [src]."))
				else
					var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
					user.apply_damage(5, BURN, hitzone)
					user.visible_message(span_warning("After a few attempts, [user] manages to light [src] - however, [user.p_they()] burn [user.p_their()] finger in the process."), span_warning("I burn myself while lighting the lighter!"))
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "burnt_thumb", /datum/mood_event/burnt_thumb)

		else
			set_lit(FALSE)
			if(fancy)
				user.visible_message(span_notice("I hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow."), span_notice("I quietly shut off [src] without even looking at what you're doing. Wow."))
			else
				user.visible_message(span_notice("[user] quietly shuts off [src]."), span_notice("I quietly shut off [src]."))
	else
		. = ..()

/obj/item/lighter/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, span_warning("The [cig.name] is already lit!"))
		if(M == user)
			cig.attackby(src, user)
		else
			if(fancy)
				cig.light(span_rose("[user] whips the [name] out and holds it for [M]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [cig] with."))
			else
				cig.light(span_notice("[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name]."))
	else
		..()

/obj/item/lighter/process()
	open_flame()

/obj/item/lighter/get_temperature()
	return lit * heat


/obj/item/lighter/greyscale
	name = "cheap lighter"
	desc = ""
	icon_state = "lighter"
	fancy = FALSE
	overlay_list = list(
		"transp",
		"tall",
		"matte",
		"zoppo" //u cant stoppo th zoppo
		)
	var/lighter_color
	var/list/color_list = list( //Same 16 color selection as electronic assemblies
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/lighter/greyscale/Initialize()
	. = ..()
	if(!lighter_color)
		lighter_color = pick(color_list)
	update_icon()

/obj/item/lighter/greyscale/update_icon()
	cut_overlays()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	lighter_overlay.color = lighter_color
	add_overlay(lighter_overlay)

/obj/item/lighter/greyscale/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='notice'>After some fiddling, [user] manages to light [A] with [src].</span>"


///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/O = target
		if(O.dry)
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume, transfered_by = user)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, span_notice("I roll the [target.name] into a rolling paper."))
			R.desc = ""
		else
			to_chat(user, span_warning("I need to dry this first!"))
