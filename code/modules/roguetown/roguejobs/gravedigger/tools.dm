/obj/item/rogueweapon/shovel
	force = 21
	possible_item_intents = list(/datum/intent/shovelscoop, /datum/intent/mace/strike/shovel)
	gripped_intents = list(/datum/intent/shovelscoop, /datum/intent/mace/strike/shovel, /datum/intent/axe/chop/stone)
	name = "shovel"
	desc = "Essential for digging (graves) in this darkened earth."
	icon_state = "shovel"
	item_state = "shovel"
	icon = 'icons/roguetown/weapons/tools.dmi'
	mob_overlay_icon = 'icons/roguetown/onmob/onmob.dmi'
	lefthand_file = 'icons/roguetown/onmob/lefthand.dmi'
	righthand_file = 'icons/roguetown/onmob/righthand.dmi'
	experimental_inhand = FALSE
	experimental_onhip = FALSE
	experimental_onback = FALSE
	gripspriteonmob = TRUE
	sharpness = IS_BLUNT
	wdefense = 3
	wlength = WLENGTH_LONG
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	swingsound = list('sound/combat/wooshes/blunt/shovel_swing.ogg','sound/combat/wooshes/blunt/shovel_swing2.ogg')
	drop_sound = 'sound/foley/dropsound/shovel_drop.ogg'
	var/obj/item/natural/dirtclod/heldclod
	smeltresult = /obj/item/ingot/iron
	max_blade_int = 50

/obj/item/rogueweapon/shovel/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(user.used_intent.type != /datum/intent/shovelscoop)
		return
	if(!istype(A, /obj/structure/snow))
		return
	var/turf/target_turf = get_turf(A)
	playsound(A,'sound/items/dig_shovel.ogg', 100, TRUE)
	qdel(A)
	for(var/dir in GLOB.cardinals)
		var/turf/card = get_step(target_turf, dir)
		if(card.snow)
			card.snow.update_corners()
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE

/obj/item/rogueweapon/shovel/Destroy()
	if(heldclod)
		QDEL_NULL(heldclod)
	return ..()

/obj/item/rogueweapon/shovel/dropped(mob/user)
	if(heldclod && isturf(loc))
		heldclod.forceMove(loc)
		heldclod = null
	update_icon()
	. = ..()

/obj/item/rogueweapon/shovel/update_icon()
	if(heldclod)
		icon_state = "dirt[initial(icon_state)]"
		item_state = "dirt[initial(icon_state)]"	// onmob itemstate does not update, TO DO
	else
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"

/datum/intent/mace/strike/shovel
	hitsound = list('sound/combat/hits/blunt/shovel_hit.ogg', 'sound/combat/hits/blunt/shovel_hit2.ogg', 'sound/combat/hits/blunt/shovel_hit3.ogg')

/datum/intent/shovelscoop
	name = "scoop"
	icon_state = "inscoop"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0
	no_attack = TRUE

/obj/item/rogueweapon/shovel/attack(mob/living/M, mob/living/user)
	. = ..()
	if(. && heldclod && get_turf(M))
		heldclod.forceMove(get_turf(M))
		heldclod = null
		update_icon()

/obj/item/rogueweapon/shovel/attack_turf(turf/T, mob/living/user)
	user.changeNext_move(user.used_intent.clickcd)
	if(user.used_intent.type == /datum/intent/shovelscoop)
		if(istype(T, /turf/open/floor/rogue/dirt))
			var/turf/open/floor/rogue/dirt/D = T
			if(heldclod)
				if(D.holie && D.holie.stage < 4)
					D.holie.attackby(src, user)
				else
					if(istype(T, /turf/open/floor/rogue/dirt/road))
						qdel(heldclod)
						T.ChangeTurf(/turf/open/floor/rogue/dirt, flags = CHANGETURF_INHERIT_AIR)
					else
						heldclod.forceMove(T)
					heldclod = null
					playsound(T,'sound/items/empty_shovel.ogg', 100, TRUE)
					update_icon()
					return
			else
				if(D.holie)
					D.holie.attackby(src, user)
				else
					if(istype(T, /turf/open/floor/rogue/dirt/road))
						new /obj/structure/closet/dirthole(T)
					else
						T.ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_INHERIT_AIR)
					heldclod = new(src)
					playsound(T,'sound/items/dig_shovel.ogg', 100, TRUE)
					update_icon()
			return
		if(heldclod)
			if(istype(T, /turf/open/water))
				qdel(heldclod)
//				T.ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_INHERIT_AIR)
			else
				heldclod.forceMove(T)
			heldclod = null
			playsound(T,'sound/items/empty_shovel.ogg', 100, TRUE)
			update_icon()
			return
		if(istype(T, /turf/open/floor/rogue/grass))
			to_chat(user, span_warning("There is grass in the way."))
			return
		return
	. = ..()


/obj/item/rogueweapon/shovel/small
	force = 7
	name = "spade"
	desc = "Indispensable for tending the soil."
	icon_state = "spade"
	item_state = "spade"
	sharpness = IS_BLUNT
	gripped_intents = null
	wlength = WLENGTH_SHORT
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	max_blade_int = 0
	grid_height = 64
	smeltresult = null

/obj/item/burial_shroud
	name = "winding sheet"
	desc = "A burial veil for the deceased."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "shroud_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/unfoldedbag_path = /obj/structure/closet/burial_shroud

/obj/item/burial_shroud/attack_self(mob/user)
	deploy_bodybag(user, user.loc)

/obj/item/burial_shroud/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/burial_shroud/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()
	user.update_a_intents()


/obj/structure/closet/burial_shroud
	name = "winding sheet"
	desc = "A burial veil for the deceased."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "shroud"
	density = FALSE
	mob_storage_capacity = 1
	open_sound = 'sound/blank.ogg'
	close_sound = 'sound/blank.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	integrity_failure = 0
	delivery_icon = null //unwrappable
	anchorable = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	drag_slowdown = 0
	horizontal = TRUE
	var/foldedbag_path = /obj/item/burial_shroud
	var/obj/item/bodybag/foldedbag_instance = null



/obj/structure/closet/burial_shroud/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/burial_shroud/open(mob/living/user)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/burial_shroud/close()
	. = ..()
	if(.)
		density = FALSE
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/burial_shroud/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(contents.len)
			to_chat(usr, span_warning("There are too many things inside of [src] to fold it up!"))
			return
		visible_message(span_notice("[usr] folds up [src]."))
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		qdel(src)

/obj/item/bodybag
	name = "body bag"
	desc = ""
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/unfoldedbag_path = /obj/structure/closet/body_bag

/obj/item/bodybag/attack_self(mob/user)
	deploy_bodybag(user, user.loc)

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()

/obj/item/bodybag/suicide_act(mob/user)
	if(isopenturf(user.loc))
		user.visible_message("<span class='suicide'>[user] is crawling into [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/obj/structure/closet/body_bag/R = new unfoldedbag_path(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/blank.ogg', 15, TRUE, -3)
		return (OXYLOSS)
	..()


/obj/structure/closet/body_bag
	name = "body bag"
	desc = ""
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/blank.ogg'
	close_sound = 'sound/blank.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	integrity_failure = 0
	delivery_icon = null //unwrappable
	anchorable = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	drag_slowdown = 0
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/open(mob/living/user)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/close()
	. = ..()
	if(.)
		density = FALSE
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(opened)
			to_chat(usr, "<span class='warning'>I wrestle with [src], but it won't fold while unzipped.</span>")
			return
		if(contents.len)
			to_chat(usr, "<span class='warning'>There are too many things inside of [src] to fold it up!</span>")
			return
		visible_message("<span class='notice'>[usr] folds up [src].</span>")
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		qdel(src)
