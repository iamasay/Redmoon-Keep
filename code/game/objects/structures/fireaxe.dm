/obj/structure/fireaxecabinet
	name = "sword rack"
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	armor = list("blunt" = 50, "slash" = 40, "stab" = 30, "bullet" = 20, "laser" = 0, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	max_integrity = 150
	integrity_failure = 0.33
	locked = FALSE
	var/open = TRUE
	var/obj/item/rogueweapon/sword/long/heirloom

/obj/structure/fireaxecabinet/Initialize()
	. = ..()
	if(prob(99))
		heirloom = new /obj/item/rogueweapon/sword/long/heirloom
	else
		heirloom = new /obj/item/rogueweapon/sword/long/judgement
	update_icon()

/obj/structure/fireaxecabinet/Destroy()
	if(heirloom)
		QDEL_NULL(heirloom)
	return ..()

/obj/structure/fireaxecabinet/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		toggle_lock(user)
	else if(I.tool_behaviour == TOOL_WELDER && user.used_intent.type == INTENT_HELP && !broken)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=2))
				return

	else if(open || broken)
		if(istype(I, /obj/item/rogueweapon/sword/long/heirloom) && !heirloom)
			var/obj/item/rogueweapon/sword/long/heirloom/F = I
			if(F.wielded)
				to_chat(user, span_warning("Unwield the [F.name] first."))
				return
			if(!user.transferItemToLoc(F, src))
				return
			heirloom = F
			to_chat(user, span_notice("I place the [F.name] back in the [name]."))
			update_icon()
			return
		else if(!broken)
			toggle_open()
	else
		return ..()

/obj/structure/fireaxecabinet/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(broken)
				playsound(loc, 'sound/blank.ogg', 90, TRUE)
			else
				playsound(loc, 'sound/blank.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/blank.ogg', 100, TRUE)

/obj/structure/fireaxecabinet/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(open)
		return
	. = ..()
	if(.)
		update_icon()

/obj/structure/fireaxecabinet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		update_icon()
		broken = TRUE
		playsound(src, 'sound/blank.ogg', 100, TRUE)
	..()

/obj/structure/fireaxecabinet/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(open || broken)
		if(heirloom)
			user.put_in_hands(heirloom)
			heirloom = null
			to_chat(user, span_notice("I take the sword from the [name]."))
			src.add_fingerprint(user)
			update_icon()
			return
	if(locked)
		to_chat(user, span_warning("The [name] won't budge!"))
		return
	else
		open = !open
		update_icon()
		return

/obj/structure/fireaxecabinet/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/structure/fireaxecabinet/attack_tk(mob/user)
	if(locked)
		to_chat(user, span_warning("The [name] won't budge!"))
		return
	else
		open = !open
		update_icon()
		return

/obj/structure/fireaxecabinet/update_icon()
	cut_overlays()
	if(heirloom)
		add_overlay("axe")
	if(!open)

		if(locked)
			add_overlay("locked")
		else
			add_overlay("unlocked")
	else
		add_overlay("glass_raised")

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)
	to_chat(user, span_notice("Resetting circuitry..."))
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	if(do_after(user, 20, target = src))
		to_chat(user, span_notice("I [locked ? "disable" : "re-enable"] the locking modules."))
		locked = !locked
		update_icon()

/obj/structure/fireaxecabinet/verb/toggle_open()
	set name = "Open/Close"
	set hidden = 1
	set src in oview(1)

	if(locked)
		to_chat(usr, span_warning("The [name] won't budge!"))
		return
	else
		open = !open
		update_icon()
		return

/obj/structure/fireaxecabinet/south
	dir = SOUTH
	pixel_y = 32

/obj/structure/fireaxecabinet/empty
    name = "empty sword rack"
    icon = 'icons/obj/wallmounts.dmi'
    icon_state = "fireaxe"
    anchored = TRUE
    density = FALSE
    armor = list("blunt" = 50, "slash" = 40, "stab" = 30, "bullet" = 20, "laser" = 0, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
    max_integrity = 150
    integrity_failure = 0.33
    locked = FALSE

/obj/structure/fireaxecabinet/empty/Initialize()
    . = ..()
    heirloom = null
    update_icon()

/obj/structure/fireaxecabinet/empty/attackby(obj/item/I, mob/user, params)
    if(open || broken)
        if(istype(I, /obj/item/rogueweapon/sword/long/heirloom) && !heirloom)
            var/obj/item/rogueweapon/sword/long/heirloom/F = I
            if(F.wielded)
                to_chat(user, span_warning("Unwield the [F.name] first."))
                return
            if(!user.transferItemToLoc(F, src))
                return
            heirloom = F
            to_chat(user, span_notice("You place the [F.name] in the [name]."))
            update_icon()
            return
        else
            to_chat(user, span_warning("Only a special sword fits in this rack."))
            return
    else
        return ..()

/obj/structure/fireaxecabinet/empty/attack_hand(mob/user)
    . = ..()
    if(.)
        return
    if(open || broken)
        if(heirloom)
            user.put_in_hands(heirloom)
            heirloom = null
            to_chat(user, span_notice("You take the sword from the [name]."))
            src.add_fingerprint(user)
            update_icon()
            return
    if(locked)
        to_chat(user, span_warning("The [name] won't budge!"))
        return
    else
        open = !open
        update_icon()
        return

/obj/structure/fireaxecabinet/empty/update_icon()
	cut_overlays()
	if(heirloom)
		add_overlay("axe")
	if(!open)
		if(locked)
			add_overlay("locked")
		else
			add_overlay("unlocked")
	else
		add_overlay("glass_raised")
