/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.
	var/lastclick
	var/category

/atom/movable/screen/Destroy()
	master = null
	hud = null
	return ..()

/atom/movable/screen/Click(location, control, params)
	if(!usr || !usr.client)
		return FALSE
	var/mob/user = usr
	var/paramslist = params2list(params)
	if(paramslist["shift"] && paramslist["left"]) // screen objects don't do the normal Click() stuff so we'll cheat
		examine_ui(user)
		return FALSE

/atom/movable/screen/proc/examine_ui(mob/user)
	var/list/inspec = list("----------------------")
	inspec += "<br><span class='notice'><b>[name]</b></span>"
	if(desc)
		inspec += "<br>[desc]"

	inspec += "<br>----------------------"
	to_chat(user, "[inspec.Join()]")


/atom/movable/screen/orbit()
	return

/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/swap_hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	name = "swap hand"

/atom/movable/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/atom/movable/screen/skills
	name = "skills"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "skills"
	screen_loc = ui_skill_menu

/atom/movable/screen/skills/Click(location, control, params)
	var/list/modifiers = params2list(params)

	if(modifiers["right"])
		var/ht
		var/mob/living/L = usr
		to_chat(L, "*----*")
		if(ishuman(usr))
			var/mob/living/carbon/human/M = usr
			if(M.charflaw)
				to_chat(M, span_info("[M.charflaw.desc]"))
				to_chat(M, "*----*")
			if(M.mind)
				if(M.mind.language_holder)
					var/finn
					for(var/X in M.mind.language_holder.languages)
						var/datum/language/LA = new X()
						finn = TRUE
						to_chat(M, span_info("[LA.name] - ,[LA.key]"))
					if(!finn)
						to_chat(M, span_warning("I don't know any languages."))
					to_chat(M, "*----*")
		for(var/X in GLOB.roguetraits)
			if(HAS_TRAIT(L, X))
				to_chat(L, "[X] - <span class='info'>[GLOB.roguetraits[X]]</span>")
				ht = TRUE
		if(!ht)
			to_chat(L, span_warning("I have no special traits."))
		to_chat(L, "*----*")
		return

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.mind.print_levels(H)

/atom/movable/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = rogueui_craft
	var/last_craft

/atom/movable/screen/craft/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(world.time < lastclick + 3 SECONDS)
		return
	lastclick = world.time

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(modifiers["right"])
			if(H.craftingthing && (H.mind?.lastrecipe != null))
				last_craft = world.time
				to_chat(H, span_warning("I am crafting \a [H.mind?.lastrecipe] again."))
				construct_item(H, H.mind?.lastrecipe)
		else
			H.playsound_local(H, 'sound/misc/click.ogg', 100)
			if(H.craftingthing)
				last_craft = world.time
				roguecraft(location, control, params, H)
			else
				testing("what")

/atom/movable/screen/area_creator
	name = "create new area"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/atom/movable/screen/area_creator/Click()
	if(usr.incapacitated() || (isobserver(usr) && !IsAdminGhost(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, span_warning("There is already a defined structure here."))
		return TRUE
	create_area(usr)

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/atom/movable/screen/language_menu/Click()
	var/mob/M = usr
	var/datum/language_holder/H = M.get_language_holder()
	H.open_language_menu(usr)

/atom/movable/screen/inventory
	/// The identifier for the slot. It has nothing to do with ID cards.
	var/slot_id
	/// Icon when empty. For now used only by humans.
	var/icon_empty
	/// Icon when contains an item. For now used only by humans.
	var/icon_full = "genslot"
	/// The overlay when hovering over with an item in your hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	nomouseover = FALSE


/atom/movable/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id, params))
		usr.update_inv_hands()
	return TRUE

/atom/movable/screen/inventory/MouseEntered(location, control, params)
	. = ..()
	add_overlays()

/atom/movable/screen/inventory/MouseExited()
	..()
	if(hud)
		cut_overlay(hud.object_overlay)
		QDEL_NULL(hud.object_overlay)

/atom/movable/screen/inventory/update_icon_state()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud?.mymob && slot_id && icon_full)
		var/obj/item/I = hud.mymob.get_item_by_slot(slot_id)
		if(I)
			icon_state = icon_full
			if(I.max_integrity)
				if(I.obj_integrity < I.max_integrity)
					icon_state = "slotdmg"
					if(I.integrity_failure)
						if((I.obj_integrity / I.max_integrity) <= I.integrity_failure)
							icon_state = "slotbroke"
		else
			icon_state = icon_empty

/atom/movable/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	cut_overlays()

	if(!user || !slot_id)
		return

	var/obj/item/holding = user.get_active_held_item()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!user.can_equip(holding, slot_id, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		item_overlay.color = "#fd0279"
	else
		item_overlay.color = "#c5c5c5"

	if(hud)
		if(hud.object_overlay)
			if(hud.overlay_curloc != src)
				hud.overlay_curloc.cut_overlay(hud.object_overlay)
		hud.overlay_curloc = src
		cut_overlay(hud.object_overlay)
		hud.object_overlay = item_overlay
		add_overlay(hud.object_overlay)


/atom/movable/screen/inventory/hand
	nomouseover =  TRUE
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/atom/movable/screen/inventory/hand/update_overlays()
	. = ..()

	if(!handcuff_overlay)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/mob/screen_gen.dmi', state)

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				. += blocked_overlay

	if(held_index == hud.mymob.active_hand_index)
		. += "hand_active"

/atom/movable/screen/inventory/hand/add_overlays()
	return

/atom/movable/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE
	if(world.time <= user.next_move)
		return TRUE

	if(user.active_hand_index == held_index)
		var/obj/item/I = user.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		user.swap_hand(held_index)
	return TRUE

/atom/movable/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"

/atom/movable/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/atom/movable/screen/close/Click()
	var/datum/component/storage/S = master
	S.hide_from(usr)
	SEND_SIGNAL(S.parent, COMSIG_STORAGE_CLOSED, usr)
	return TRUE

/atom/movable/screen/drop
	name = "drop"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/drop/Click()
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/atom/movable/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/atom/movable/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/atom/movable/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

/atom/movable/screen/act_intent/proc/switch_intent(index as num)
	return



/atom/movable/screen/act_intent/rogintent
	name = ""
	desc = ""
	icon = 'icons/mob/rogueintentbase.dmi'
	icon_state = "intentbase"
	screen_loc = rogueui_intents
	var/intent1
	var/intent2
	var/intent3
	var/intent4
	var/border1
	var/border2

/atom/movable/screen/act_intent/rogintent/update_icon(list/intentsl,list/intentsr, oactive = FALSE)
	..()
	cut_overlays(TRUE)
	if(!intentsl || !intentsr)
		return
	else
		var/lol = 0
//		intent1 = image(icon='icons/mob/rogueintentbase.dmi',icon_state="intentbase")
//		add_overlay(intent1, TRUE)
		var/list/used = intentsr
		if(hud.mymob.active_hand_index == 1)
			used = intentsl
		for(var/datum/intent/intenty in used)
			lol++
			switch(lol)
				if(1)
					intent1 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 64, pixel_y = 16, layer = layer+0.02)
					add_overlay(intent1, TRUE)
				if(2)
					intent2 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 96, pixel_y = 16, layer = layer+0.02)
					add_overlay(intent2, TRUE)
				if(3)
					intent3 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 64, layer = layer+0.02)
					add_overlay(intent3, TRUE)
				if(4)
					intent4 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 96, layer = layer+0.02)
					add_overlay(intent4, TRUE)
		if(ismob(usr))
			var/mob/M = usr
			switch_intent(M.r_index, M.l_index, oactive)

/atom/movable/screen/act_intent/rogintent/switch_intent(r_index, l_index, oactive = FALSE)
	cut_overlay(border1, TRUE)
	cut_overlay(border2, TRUE)
	var/used = "offintent"
	if(oactive)
		used = "offintentselected"
	if(!r_index || !l_index)
		return
	else
		var/used_index = r_index
		var/other = l_index
		if(hud.mymob.active_hand_index == 1)
			used_index = l_index
			other = r_index
		switch(used_index)
			if(1)
				border1 = image(icon='icons/mob/ru_roguehud.dmi',icon_state="intentselected", pixel_x = 64, pixel_y = 16, layer = layer+0.01)
			if(2)
				border1 = image(icon='icons/mob/ru_roguehud.dmi',icon_state="intentselected", pixel_x = 96, pixel_y = 16, layer = layer+0.01)
			if(3)
				border1 = image(icon='icons/mob/ru_roguehud.dmi',icon_state="intentselected", pixel_x = 64, layer = layer+0.01)
			if(4)
				border1 = image(icon='icons/mob/ru_roguehud.dmi',icon_state="intentselected", pixel_x = 96, layer = layer+0.01)
		switch(other)
			if(1)
				border2 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=used, pixel_x = 64, pixel_y = 16, layer = layer+0.01)
			if(2)
				border2 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=used, pixel_x = 96, pixel_y = 16, layer = layer+0.01)
			if(3)
				border2 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=used, pixel_x = 64, layer = layer+0.01)
			if(4)
				border2 = image(icon='icons/mob/ru_roguehud.dmi',icon_state=used, pixel_x = 96, layer = layer+0.01)
		add_overlay(border2, TRUE)
		add_overlay(border1, TRUE)

/atom/movable/screen/act_intent/rogintent/Click(location, control, params)

	var/list/modifiers = params2list(params)

	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE

	user.playsound_local(user, 'sound/misc/click.ogg', 100)

	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])
		var/clicked = get_index_at_loc(_x, _y)
		if(!clicked)
			return
/*		if(_x<=64)
			if(user.active_hand_index == 2)
				if(modifiers["right"])
					if(clicked != user.l_index)
						user.rog_intent_change(clicked,1)
					else
						if(user.oactive)
							user.oactive = FALSE
//						else
//							user.oactive = TRUE
						switch_intent(user.r_index, user.l_index, user.oactive)
					return
				if(!user.swap_hand(1))
					return
			if(modifiers["left"])
				if(modifiers["shift"])
					user.examine_intent(clicked, FALSE)
					return
			user.rog_intent_change(clicked)
		else*/
//			if(user.active_hand_index == 1)
//				if(modifiers["right"])
//					if(clicked != user.r_index)
//						user.rog_intent_change(clicked,1)
//					else
//						if(user.oactive)
//							user.oactive = FALSE
//						else
//							user.oactive = TRUE
//						switch_intent(user.r_index, user.l_index, user.oactive)
//					return
//				if(!user.swap_hand(2))
//					return
		if(modifiers["left"])
			if(modifiers["shift"])
				user.examine_intent(clicked, FALSE)
				return
		user.rog_intent_change(clicked)

/atom/movable/screen/act_intent/rogintent/proc/get_index_at_loc(xl, yl)
/*	if(xl<=64)
		if(xl<32)
			if(yl>16)
				return 1
			else
				return 3
		else
			if(yl>16)
				return 2
			else
				return 4
	else*/
	if(xl > 64)
		if(xl<96)
			if(yl>16)
				return 1
			else
				return 3
		else
			if(yl>16)
				return 2
			else
				return 4

//

/atom/movable/screen/quad_intents
	name = "mmb intents"
	icon_state = "mmbintents0"
	icon = 'icons/mob/ru_roguehud.dmi'
	screen_loc = rogueui_quad

/atom/movable/screen/quad_intents/proc/switch_intent(input)
	icon_state = "mmbintents0"
	if(input in 1 to 4)
		icon_state = "mmbintents[input]"

/atom/movable/screen/quad_intents/Click(location, control, params)
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)

	var/_y = text2num(params2list(params)["icon-y"])

	if(_y<=9)
		usr.mmb_intent_change(QINTENT_STEAL)

	else if(_y>=9 && _y<=16)
		usr.mmb_intent_change(QINTENT_KICK)

	else if(_y>=17 && _y<=24)
		usr.mmb_intent_change(QINTENT_JUMP)

	else if(_y>=24 && _y<=32)
		usr.mmb_intent_change(QINTENT_BITE)


/atom/movable/screen/give_intent
	name = "give/take"
	icon_state = "take0"
	icon = 'icons/mob/ru_roguehud.dmi'
	screen_loc = rogueui_give
	var/giving = 0

/atom/movable/screen/give_intent/proc/switch_intent(ass)
	if(ass == QINTENT_GIVE)
		giving = 1
	else
		giving = 0
	update_icon()

/atom/movable/screen/give_intent/Click(location, control, params)
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	usr.mmb_intent_change(QINTENT_GIVE)

/atom/movable/screen/give_intent/update_icon()
	..()
	if(ismob(usr))
		var/mob/M = usr
		if(M.get_active_held_item())
			icon_state = "give[giving]"
		else
			icon_state = "take[giving]"

//

/atom/movable/screen/def_intent
	name = "defense intent"
	icon_state = "def1n"
	icon = 'icons/mob/ru_roguehud.dmi'
	screen_loc = rogueui_def

/atom/movable/screen/def_intent/update_icon()
	icon_state = "def[hud.mymob.d_intent]n"

/atom/movable/screen/def_intent/Click(location, control, params)
	var/_y = text2num(params2list(params)["icon-y"])

	if(_y>=0 && _y<17)
		usr.def_intent_change(INTENT_DODGE)
	else if(_y>16 && _y<=32)
		usr.def_intent_change(INTENT_PARRY)


/atom/movable/screen/cmode
	name = "combat mode"
	icon_state = "combat0"
	icon = 'icons/mob/ru_roguehud.dmi'
	screen_loc = rogueui_cmode

/atom/movable/screen/cmode/update_icon()
	icon_state = "combat[hud.mymob.cmode]"

/atom/movable/screen/cmode/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(isliving(usr))
		var/mob/living/L = usr
		L.playsound_local(L, 'sound/misc/click.ogg', 100)
		if(modifiers["right"])
			L.submit()
		else
			L.toggle_cmode()
			update_icon()

/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/atom/movable/screen/mov_intent/Click(location, control, params)
	toggle(usr)

/atom/movable/screen/mov_intent/update_icon_state()
	switch(hud?.mymob?.m_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"

/atom/movable/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_move_intent(user)

/atom/movable/screen/rogmove
	name = "sneak mode"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "sneak0"
	screen_loc = rogueui_moves

/atom/movable/screen/rogmove/Click(location, control, params)
	var/mob/M = usr
	toggle(M)

/atom/movable/screen/rogmove/proc/toggle(mob/user)
	if(isobserver(user))
		return
	if(user.m_intent == MOVE_INTENT_SNEAK)
		user.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		user.toggle_rogmove_intent(MOVE_INTENT_SNEAK)
	update_icon_state()
	user.update_sneak_invis()

/atom/movable/screen/rogmove/update_icon_state()
	if(hud?.mymob?.m_intent == MOVE_INTENT_SNEAK)
		icon_state = "sneak1"
	else
		icon_state = "sneak0"

/atom/movable/screen/rogmove/sprint
	name = "sprint mode"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "sprint0"
	screen_loc = rogueui_moves

/atom/movable/screen/rogmove/sprint/toggle(mob/user)
	if(isobserver(user))
		return
	if(user.m_intent == MOVE_INTENT_RUN)
		user.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		user.toggle_rogmove_intent(MOVE_INTENT_RUN)
	update_icon_state()

/atom/movable/screen/rogmove/sprint/update_icon_state()
	if(hud?.mymob?.m_intent == MOVE_INTENT_RUN)
		icon_state = "sprint1"
	else
		icon_state = "sprint0"



/atom/movable/screen/advsetup
	name = ""
	icon = null
	icon_state = ""

/atom/movable/screen/advsetup/New(client/C) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_mob)), 30)

/atom/movable/screen/advsetup/Destroy()
	hud.static_inventory -= src
	return ..()

/atom/movable/screen/advsetup/proc/check_mob()
	if(QDELETED(src))
		return
	if(!hud)
		qdel(src)
		return
	if(!ishuman(hud.mymob))
		qdel(src)
		return
	var/mob/living/carbon/human/H = hud.mymob
	if(H.mind && H.mind.antag_datums)
		for(var/datum/antagonist/D in H.mind.antag_datums)
			if(istype(D, /datum/antagonist/vampirelord) || istype(D, /datum/antagonist/vampire) || istype(D, /datum/antagonist/bandit) || istype(D, /datum/antagonist/lich) || istype(D, /datum/antagonist/vurdalak))
				qdel(src)
				return
	if(H.advsetup)
		alpha = 0
		icon = 'icons/mob/advsetup.dmi'
		animate(src, alpha = 255, time = 30)

/atom/movable/screen/advsetup/Click(location,control,params)
	if(!hud)
		qdel(src)
		return
	if(!ishuman(hud.mymob))
		qdel(src)
		return
	var/mob/living/carbon/human/H = hud.mymob
	if(!H.advsetup)
		qdel(src)
		return
	else
		SSrole_class_handler.setup_class_handler(H)

/atom/movable/screen/eye_intent
	name = "eye intent"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "eye"

/atom/movable/screen/eye_intent/Click(location,control,params)
	var/list/modifiers = params2list(params)
	var/_y = text2num(params2list(params)["icon-y"])

	hud.mymob.playsound_local(hud.mymob, 'sound/misc/click.ogg', 100)
	if(isliving(hud?.mymob))
		var/mob/living/L = hud.mymob
		if(L.eyesclosed)
			L.eyesclosed = 0
			L.cure_blind("eyelids")

	if(modifiers["left"])
		if(_y>=29 || _y<=4)
			if(isliving(hud.mymob))
				var/mob/living/L = hud.mymob
				L.eyesclosed = 1
				L.become_blind("eyelids")
		else
			toggle(usr)

	if(modifiers["middle"])
		if(isliving(hud.mymob))
			var/mob/living/L = hud.mymob
			L.look_up()
	update_icon()

	if(modifiers["right"])
		if(isliving(hud.mymob))
			var/mob/living/L = hud.mymob
			L.look_around()

/atom/movable/screen/eye_intent/update_icon_state()
	. = ..()
	var/mob/living/L = hud.mymob
	if(!istype(L))
		icon_state = "eye"
		return
	if(L.eyesclosed)
		icon_state = "eye_closed"
	else if(L.tempfixeye)
		icon_state = "eye_target"
	else if(L.fixedeye)
		icon_state = "eye_fixed"
	else
		icon_state = "eye"

/atom/movable/screen/eye_intent/update_overlays()
	. = ..()
	var/mob/living/carbon/human/human = hud.mymob
	if(!istype(human))
		return
	var/mutable_appearance/iris = mutable_appearance(src.icon, "oeye")
	switch(icon_state)
		if("eye_closed")
			iris.icon_state = "oeye_closed"
		if("eye_target")
			iris.icon_state = "oeye_target"
		if("eye_fixed")
			iris.icon_state = "oeye_fixed"
		else
			iris.icon_state = "oeye"
	iris.color = human.get_eye_color()
	. += iris

/atom/movable/screen/eye_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_eye_intent(user)

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/atom/movable/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/atom/movable/screen/rest
	name = "rest"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/atom/movable/screen/rest/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return

	if(!user.resting)
		icon_state = "act_rest"
	else
		icon_state = "act_rest0"

/atom/movable/screen/restup
	name = "stand up"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest_up"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/restup/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.stand_up()

/atom/movable/screen/restdown
	name = "lay down"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest_down"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/restdown/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/atom/movable/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/atom/movable/screen/storage/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		if(master)
			var/obj/item/flipper = usr.get_active_held_item()
			if(!flipper || (!usr.Adjacent(flipper) && !usr.DirectAccess(flipper)) || !isliving(usr) || usr.incapacitated(ignore_grab = TRUE))
				return
			var/old_width = flipper.grid_width
			var/old_height = flipper.grid_height
			flipper.grid_height = old_width
			flipper.grid_width = old_height
			update_hovering(location, control, params)
			return

	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated(ignore_grab = TRUE))
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_held_item()
		if(I)
			master.attackby(src, I, usr, params, TRUE)
	return TRUE


/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "catch0"
	var/throwy = 0

/atom/movable/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/throw_catch/update_icon()
	..()
	if(ismob(usr))
		var/mob/M = usr
		if(M.get_active_held_item())
			icon_state = "throw[throwy]"
		else
			icon_state = "catch[throwy]"

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "m-zone_sel"
	screen_loc = rogueui_targetdoll
	var/overlay_icon = 'icons/mob/roguehud64.dmi'
	var/static/list/hover_overlays_cache = list()
	var/hovering
	var/arrowheight = 0

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(ismob(hud.mymob))
		var/mob/M = hud.mymob
		if(M.gender == FEMALE)
			choice = get_zone_at(icon_x, icon_y, FEMALE)
	if (!choice)
		return 1

	if(PL["right"] && ishuman(hud.mymob))
		var/mob/living/carbon/human/H = hud.mymob
		return H.check_limb_for_injuries(H, choice = check_zone(choice))
	else
		return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	choice = "m_[choice]"
	if(ismob(hud.mymob))
		var/mob/M = hud.mymob
		if(M.gender == FEMALE)
			choice = get_zone_at(icon_x, icon_y, FEMALE)
			choice = "f_[choice]"

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice


	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
//		overlay_object.icon_state = "[basedholder]-[choice]"
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/mob/roguehud64.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	layer = ABOVE_HUD_LAYER+0.2
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y, gender = MALE)
	if(gender == MALE)
		switch(icon_y)
			if(1 to 3)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_PRECISE_R_INHAND
					if(17 to 28)
						return BODY_ZONE_PRECISE_R_FOOT
					if(38 to 49)
						return BODY_ZONE_PRECISE_L_FOOT
					if(59 to 61)
						return BODY_ZONE_PRECISE_L_INHAND
			if(4 to 5)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_PRECISE_R_INHAND
					if(17 to 28)
						return BODY_ZONE_PRECISE_R_FOOT
					if(38 to 49)
						return BODY_ZONE_PRECISE_L_FOOT
					if(59 to 61)
						return BODY_ZONE_PRECISE_L_INHAND
			if(6 to 15)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_PRECISE_R_INHAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(59 to 61)
						return BODY_ZONE_PRECISE_L_INHAND
			if(16 to 21)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_PRECISE_R_INHAND
					if(12 to 18)
						return BODY_ZONE_PRECISE_R_HAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(48 to 54)
						return BODY_ZONE_PRECISE_L_HAND
					if(59 to 61)
						return BODY_ZONE_PRECISE_L_INHAND
			if(22 to 24)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_PRECISE_R_INHAND
					if(12 to 18)
						return BODY_ZONE_PRECISE_R_HAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(48 to 54)
						return BODY_ZONE_PRECISE_L_HAND
					if(59 to 61)
						return BODY_ZONE_PRECISE_L_INHAND
			if(25 to 29)
				switch(icon_x)
					if(16 to 22)
						return BODY_ZONE_R_ARM
					if(27 to 39)
						return BODY_ZONE_PRECISE_STOMACH
					if(44 to 50)
						return BODY_ZONE_L_ARM
			if(30 to 38)
				switch(icon_x)
					if(16 to 22)
						return BODY_ZONE_R_ARM
					if(24 to 42)
						return BODY_ZONE_CHEST
					if(44 to 50)
						return BODY_ZONE_L_ARM
			if(39)
				switch(icon_x)
					if(29 to 37)
						return BODY_ZONE_PRECISE_NECK
			if(40 to 46)
				switch(icon_x)
					if(27 to 39)
						if(icon_y in 40 to 41)
							if(icon_x in 29 to 37)
								return BODY_ZONE_PRECISE_NECK
						if(icon_y in 42 to 44)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_MOUTH
						if(icon_y == 46)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						return BODY_ZONE_HEAD
			if(47 to 50)
				switch(icon_x)
					if(24 to 26)
						return BODY_ZONE_PRECISE_EARS
					if(27 to 39)
						if(icon_y in 49 to 50)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 47 to 48)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						return BODY_ZONE_HEAD
					if(40 to 42)
						return BODY_ZONE_PRECISE_EARS
			if(51 to 55)
				switch(icon_x)
					if(27 to 39)
						if(icon_y == 51)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 53 to 55)
							if(icon_x in 29 to 37)
								return BODY_ZONE_PRECISE_SKULL
						return BODY_ZONE_HEAD
	else
		switch(icon_y)
			if(1 to 7)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_PRECISE_R_INHAND
					if(26 to 32)
						return BODY_ZONE_PRECISE_R_FOOT
					if(34 to 40)
						return BODY_ZONE_PRECISE_L_FOOT
					if(52 to 54)
						return BODY_ZONE_PRECISE_L_INHAND
			if(8 to 16)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_PRECISE_R_INHAND
					if(24 to 31)
						return BODY_ZONE_R_LEG
					if(35 to 42)
						return BODY_ZONE_L_LEG
					if(52 to 54)
						return BODY_ZONE_PRECISE_L_INHAND
			if(17 to 20)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_PRECISE_R_INHAND
					if(20 to 23)
						return BODY_ZONE_PRECISE_R_HAND
					if(24 to 31)
						return BODY_ZONE_R_LEG
					if(35 to 42)
						return BODY_ZONE_L_LEG
					if(43 to 46)
						return BODY_ZONE_PRECISE_L_HAND
					if(52 to 54)
						return BODY_ZONE_PRECISE_L_INHAND
			if(21)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_PRECISE_R_INHAND
					if(20 to 23)
						return BODY_ZONE_PRECISE_R_HAND
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(43 to 46)
						return BODY_ZONE_PRECISE_L_HAND
					if(52 to 54)
						return BODY_ZONE_PRECISE_L_INHAND
			if(22 to 23)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_PRECISE_R_INHAND
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(41 to 46)
						return BODY_ZONE_L_ARM
					if(52 to 54)
						return BODY_ZONE_PRECISE_L_INHAND
			if(24 to 29)
				switch(icon_x)
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(28 to 38)
						return BODY_ZONE_PRECISE_STOMACH
					if(41 to 46)
						return BODY_ZONE_L_ARM
			if(30 to 37)
				switch(icon_x)
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(27 to 39)
						return BODY_ZONE_CHEST
					if(41 to 46)
						return BODY_ZONE_L_ARM
			if(38 to 39)
				switch(icon_x)
					if(30 to 36)
						return BODY_ZONE_PRECISE_NECK
			if(40 to 43)
				switch(icon_x)
					if(28 to 38)
						if(icon_y == 40)
							if(icon_x in 30 to 36)
								return BODY_ZONE_PRECISE_NECK
						if(icon_y in 41 to 43)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_MOUTH
						return BODY_ZONE_HEAD
			if(44 to 47)
				switch(icon_x)
					if(26 to 27)
						return BODY_ZONE_PRECISE_EARS
					if(28 to 38)
						if(icon_y in 44 to 46)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						if(icon_y == 47)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						return BODY_ZONE_HEAD
					if(39 to 40)
						return BODY_ZONE_PRECISE_EARS
			if(48 to 51)
				switch(icon_x)
					if(28 to 38)
						if(icon_y in 48 to 49)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 50 to 51)
							if(icon_x in 30 to 36)
								return BODY_ZONE_PRECISE_SKULL
						return BODY_ZONE_HEAD
			if(52)
				if(icon_x in 30 to 36)
					return BODY_ZONE_PRECISE_SKULL

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(user != hud?.mymob)
		return

	if(choice != hud.mymob.zone_selected)
		hud.mymob.select_zone(choice)
		update_icon()

	return TRUE

/atom/movable/screen/zone_sel/update_overlays()
	. = ..()
	if(!hud?.mymob)
		return

	icon_state = "[hud.mymob.gender == "male" ? "m" : "f"]-zone_sel"

	if(hud.mymob.stat != DEAD && ishuman(hud.mymob))
		var/mob/living/carbon/human/H = hud.mymob
		for(var/X in H.bodyparts)
			var/obj/item/bodypart/BP = X
			if(BP.body_zone in H.get_missing_limbs())
				continue
			if(HAS_TRAIT(H, TRAIT_NOPAIN))
				var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]")
				limby.color = "#78a8ba"
				. += limby
				continue
			var/damage = BP.burn_dam + BP.brute_dam
			if(damage > BP.max_damage)
				damage = BP.max_damage
			var/comparison = (damage/BP.max_damage)
			. += mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]") //apply healthy limb
			var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]w-[BP.body_zone]") //apply wounded overlay
			limby.alpha = (comparison*255)*2
			. += limby
			if(BP.get_bleed_rate())
				. += mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]-bleed") //apply healthy limb
		for(var/X in H.get_missing_limbs())
			var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[X]") //missing limb
			limby.color = "#2f002f"
			. += limby

	. += mutable_appearance(overlay_icon, "[hud.mymob.gender == "male" ? "m" : "f"]_[hud.mymob.zone_selected]")
//	. += mutable_appearance(overlay_icon, "height_arrow[hud.mymob.aimheight]")

/atom/movable/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'

/atom/movable/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/atom/movable/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healthdoll
	name = "health doll"
	screen_loc = rogueui_targetdoll

/atom/movable/screen/healthdoll/Click(location, control, params)
	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.check_for_injuries(H)

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = null

/atom/movable/screen/healths/blood
	name = "life"
	icon_state = "blood100"
	screen_loc = rogueui_blood
	icon = 'icons/mob/rogueheat.dmi'

/atom/movable/screen/healths/blood/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(modifiers["left"])
			H.check_for_injuries(H)
		if(modifiers["right"])
			if(!H.mind)
				return
			if(length(H.mind.known_people))
				H.mind.display_known_people(H)
			else
				to_chat(H, span_warning("I don't know anyone."))

/atom/movable/screen/splash
	icon = 'icons/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER+1
	plane = SPLASHSCREEN_PLANE
	var/client/holder
	var/fucme = TRUE

/atom/movable/screen/splash/credits
	icon = 'icons/fullblack.dmi'
	icon_state = ""
	screen_loc = ui_backhudl
	layer = SPLASHSCREEN_LAYER
	fucme = FALSE

/atom/movable/screen/splash/New(client/C, visible, use_previous_title) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	if(fucme)
		if(!use_previous_title)
			if(SStitle.icon)
				icon = SStitle.icon
		else
			if(!SStitle.previous_icon)
				qdel(src)
				return
			icon = SStitle.previous_icon

	holder.screen += src

/atom/movable/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/atom/movable/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/atom/movable/screen/gameover
	icon = 'icons/gameover.dmi'
	icon_state = ""
	screen_loc = ui_backhudl
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE

/atom/movable/screen/gameover/proc/Fade(out = FALSE, qdel_after = FALSE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30, flags = ANIMATION_PARALLEL)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30, flags = ANIMATION_PARALLEL)
	if(qdel_after)
		QDEL_IN(src, 30)


/atom/movable/screen/gameover/hog
	icon_state = "hog"
	alpha = 0

/atom/movable/screen/gameover/hog/Fade(out = FALSE, qdel_after = FALSE)
	if(QDELETED(src))
		return
//	icon_state = "blank"
//	var/image/MA = image(icon, "hog")
//	MA.alpha = 0
//	add_overlay(MA)
//	animate(MA, alpha = 255, time = 30)
	if(!out)
		animate(src, alpha = 255, time = 30, flags = ANIMATION_PARALLEL)
	else
		animate(src, alpha = 0, time = 30, flags = ANIMATION_PARALLEL)
		QDEL_IN(src, 30)

/atom/movable/screen/component_button
	var/atom/movable/screen/parent

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/parent)
	. = ..()
	src.parent = parent

/atom/movable/screen/component_button/Click(location, control, params)
	if(parent)
		parent.component_click(src, params)

//Roguehud objects

/atom/movable/screen/backhudl
	icon = 'icons/mob/roguehudback2.dmi'
	icon_state = ""
	name = " "
	screen_loc = ui_backhudl
	layer = BACKHUD_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/backhudl/Click()
	return

/atom/movable/screen/backhudl/ghost
	icon_state = "dead"
	icon = 'icons/mob/roguehudbackghost.dmi'

/atom/movable/screen/backhudl/obs
	icon_state = "obs"
	icon = 'icons/mob/roguehudbackghost.dmi'

/atom/movable/screen/aim
	name = ""
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "aimbg"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/aim/boxaim
	name = "tile selection indicator"
	icon_state = "boxoff"

/atom/movable/screen/aim/boxaim/Click()
	if(ismob(usr))
		var/mob/M = usr
		if(M.boxaim == TRUE)
			M.boxaim = FALSE
		else
			M.boxaim = TRUE
		update_icon()

/atom/movable/screen/aim/boxaim/update_icon()
	if(ismob(usr))
		var/mob/living/M = usr
		if(M.boxaim == TRUE)
			icon_state = "boxon"
		else
			icon_state = "boxoff"
			if(M.client)
				M.client.mouseoverbox.screen_loc = null
	..()


/atom/movable/screen/stress
	name = "sanity"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "stressback"

/atom/movable/screen/stress/update_icon()
	cut_overlays()
	var/state2use = "stress1"
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(!HAS_TRAIT(H, TRAIT_NOMOOD))
			var/stress_amt = H.get_stress_amount()
			if(stress_amt > 0)
				state2use = "stress2"
			if(stress_amt >= 5)
				state2use = "stress3"
			if(stress_amt >= 15)
				state2use = "stress4"
			if(stress_amt >= 25)
				state2use = "stress5"
		if(H.has_status_effect(/datum/status_effect/buff/drunk))
			state2use = "mood_drunk"
		if(H.has_status_effect(/datum/status_effect/buff/druqks))
			state2use = "mood_drunk"
		if(H.InFullCritical())
			state2use = "stress4"
		if(H.mind)
			if(H.mind.has_antag_datum(/datum/antagonist/zombie))
				state2use = "stress4"
		if(H.stat == DEAD)
			state2use = "mood_dead"
	add_overlay(state2use)

/atom/movable/screen/stress/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(ishuman(usr))
		var/mob/living/carbon/human/M = usr
		if(modifiers["left"])
			if(M.charflaw)
				to_chat(M, "*----*")
				to_chat(M, span_info("[M.charflaw.desc]"))
			to_chat(M, "*--------*")
			var/list/already_printed = list()
			var/list/pos_stressors = M.get_positive_stressors()
			for(var/datum/stressevent/S in pos_stressors)
				if(S in already_printed)
					continue
				var/cnt = 1
				for(var/datum/stressevent/CS in pos_stressors)
					if(CS == S)
						continue
					if(CS.type == S.type)
						cnt++
						already_printed += CS
				var/ddesc = S.desc
				if(islist(S.desc))
					ddesc = pick(S.desc)
				if(cnt > 1)
					to_chat(M, "[ddesc] (x[cnt])")
				else
					to_chat(M, "[ddesc]")
			var/list/neg_stressors = M.get_negative_stressors()
			for(var/datum/stressevent/S in neg_stressors)
				if(S in already_printed)
					continue
				var/cnt = 1
				for(var/datum/stressevent/CS in neg_stressors)
					if(CS == S)
						continue
					if(CS.type == S.type)
						cnt++
						already_printed += CS
				var/ddesc = S.desc
				if(islist(S.desc))
					ddesc = pick(S.desc)
				if(cnt > 1)
					to_chat(M, "[ddesc] (x[cnt])")
				else
					to_chat(M, "[ddesc]")
			already_printed = list()
			to_chat(M, "*--------*")
		if(modifiers["right"])
			if(M.get_triumphs() <= 0)
				to_chat(M, span_warning("I haven't TRIUMPHED."))
				return
			if(alert("Do you want to remember a TRIUMPH?", "", "Yes", "No") == "Yes")
				if(!M.has_stress_event(/datum/stressevent/triumph))
					M.add_stress(/datum/stressevent/triumph)
					M.adjust_triumphs(-1)
					M.playsound_local(M, 'sound/misc/notice (2).ogg', 100, FALSE)


/atom/movable/screen/rmbintent
	name = "alt intents"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "rmbintent"
	var/list/shown_intents = list()
	var/showing = FALSE

/atom/movable/screen/rmbintent/update_icon()
	testing("overlayscut")
	cut_overlays()
	if(isliving(hud?.mymob))
		var/mob/living/L = hud.mymob
		if(L.rmb_intent)
//			var/image/I = image(icon='icons/mob/ru_roguehud.dmi',icon_state="[L.rmb_intent.icon_state]_x", layer = layer+0.01)
			add_overlay("[L.rmb_intent.icon_state]_x")
			name = L.rmb_intent.name
			desc = L.rmb_intent.desc

/atom/movable/screen/rmbintent/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(isliving(usr))
		var/mob/living/M = usr
		if(modifiers["left"])
			if(showing)
				collapse_intents()
			else
				show_intents(M)
		if(modifiers["right"])
			if(M.rmb_intent)
				to_chat(M, span_info("* --- *"))
				to_chat(M, span_info("[name]: [desc]"))
				to_chat(M, span_info("* --- *"))

/atom/movable/screen/rmbintent/proc/collapse_intents()
	if(!showing)
		return
	showing = FALSE
	QDEL_LIST(shown_intents)
	update_icon()

/atom/movable/screen/rmbintent/proc/show_intents(mob/living/M)
	if(showing)
		return
	if(!M)
		return
	showing = TRUE
	var/cnt
	var/i = 15
	var/they = 0.02
	for(var/X in M.possible_rmb_intents)
		if(M.rmb_intent?.type == X)
			continue
		var/atom/movable/screen/rintent_selection/R = new(M.client)
		var/datum/rmb_intent/RI = new X
		R.stored_intent = X
		R.icon_state = RI.icon_state
		R.name = RI.name
		R.desc = RI.desc
		shown_intents += R
		R.screen_loc = "WEST-4:0,SOUTH+8:[i]"
		R.layer = layer+they
		i += 15
		they += 0.01
		cnt++
	if(!cnt)
		showing = FALSE

/atom/movable/screen/rmbintent/Destroy()
	QDEL_LIST(shown_intents)
	. = ..()

/atom/movable/screen/rintent_selection
	name = "rmb intent"
	icon = 'icons/mob/ru_roguehud.dmi'
	icon_state = "rmbaimed"
	var/stored_intent
	var/stored_name
	var/client/holder

/atom/movable/screen/rintent_selection/New(client/C)
	if(C)
		holder = C
	. = ..()
	holder.screen += src

/atom/movable/screen/rintent_selection/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/atom/movable/screen/rintent_selection/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(isliving(usr))
		var/mob/living/M = usr
		if(modifiers["left"])
			if(stored_intent)
				M.swap_rmb_intent(type = stored_intent)
		if(modifiers["right"])
			to_chat(M, span_info("* --- *"))
			to_chat(M, span_info("[name]: [desc]"))
			to_chat(M, span_info("* --- *"))

/mob/living/proc/swap_rmb_intent(type, num)
	if(!possible_rmb_intents?.len)
		return
	if(type)
		if(type in possible_rmb_intents)
			rmb_intent = new type()
			if(hud_used?.rmb_intent)
				hud_used.rmb_intent.update_icon()
				hud_used.rmb_intent.collapse_intents()
	if(num)
		if(possible_rmb_intents.len < num)
			return
		var/A = possible_rmb_intents[num]
		if(A)
			rmb_intent = new A()
			if(hud_used?.rmb_intent)
				hud_used.rmb_intent.update_icon()
				hud_used.rmb_intent.collapse_intents()

/mob/living/proc/cycle_rmb_intent()
    if(!possible_rmb_intents?.len)
        return

    // Find the index of the current intent
    var/index = possible_rmb_intents.Find(rmb_intent)

    if(index == -1)
        rmb_intent = possible_rmb_intents[1]
    else
        // Calculate the next index, wrapping around if at the end
        index = (index % possible_rmb_intents.len) + 1
        rmb_intent = possible_rmb_intents[index]

    if(hud_used?.rmb_intent)
    {
        hud_used.rmb_intent.update_icon()
        hud_used.rmb_intent.collapse_intents()
    }

/atom/movable/screen/time
	name = "Sir Sun"
	icon = 'icons/time.dmi'
	icon_state = "day"

/atom/movable/screen/time/update_icon()
	cut_overlays()
	switch(GLOB.tod)
		if("day")
			icon_state = "day"
			name = "Sir Sun"
		if("dusk")
			icon_state = "dusk"
			name = "Sir Sun - Dusk"
		if("night")
			icon_state = "night"
			name = "Miss Moon"
		if("dawn")
			icon_state = "dawn"
			name = "Sir Sun - Dawn"
	for(var/datum/weather/rain/R in SSweather.curweathers)
		if(R.stage < 2)
			add_overlay("clouds")
		if(R.stage == 2)
			add_overlay("rainlay")

/atom/movable/screen/stamina
	name = "stamina"
	desc = "My long-term weariness. Rest will be needed to recover this."
	icon_state = "fat100"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat

/atom/movable/screen/energy
	name = "energy"
	desc = "How winded I am. I need only a moment to catch my breath."
	icon_state = "stam100"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat

/atom/movable/screen/heatstamover
	name = ""
	mouse_opacity = 0
	icon_state = "heatstamover"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat
	layer = HUD_LAYER+0.1

/atom/movable/screen/grain
	icon = 'icons/grain.dmi'
	icon_state = "grain"
	name = ""
	screen_loc = "1,1"
	mouse_opacity = 0
	alpha = 55 // I DO SEE NOTHING WITH 70 ALPHA
//	layer = 20.5
//	plane = 20
	layer = 13
	plane = 0
	blend_mode = 4

/atom/movable/screen/scannies
	icon = 'icons/mob/roguehudback2.dmi'
	icon_state = "crt"
	name = ""
	screen_loc = ui_backhudl
	mouse_opacity = 0
	alpha = 0
	layer = 24
	plane = 24
	blend_mode = BLEND_MULTIPLY

/atom/movable/screen/char_preview
	name = "Me."
	icon_state = ""
//	var/list/prevcolors = list("background-color=#000000","background-color=#242f28","background-color=#302323","background-color=#999a63","background-color=#7e7e7e")

//atom/movable/screen/char_preview/Click()
//	winset(usr.client, "preferencess_window.character_preview_map", pick(prevcolors))

#define READ_RIGHT 1
#define READ_LEFT 2
#define READ_BOTH 3

/atom/movable/screen/read
	icon = 'icons/roguetown/hud/read.dmi'
	icon_state = ""
	name = ""
	screen_loc = "1,1"
	layer = HUD_LAYER+0.01
	plane = HUD_PLANE
	alpha = 0
	var/atom/movable/screen/readtext/textright
	var/atom/movable/screen/readtext/textleft
	var/reading

/atom/movable/screen/read/Click(location, control, params)
	. = ..()
	destroy_read()
	if(!usr || !usr.client)
		return FALSE
	var/mob/user = usr
	user << browse(null, "window=reading")

/atom/movable/screen/read/proc/destroy_read()
	if(textright)
		textright.alpha = 0
		textleft.maptext = null
	if(textleft)
		textleft.alpha = 0
		textleft.maptext = null
	alpha = 0
	icon_state = ""
	reading = FALSE

/atom/movable/screen/read/proc/show()
	alpha = 255
	reading = TRUE

/atom/movable/screen/read/proc/show_text(input)
	reading = TRUE
	animate(src, alpha = 255, time = 5, easing = EASE_IN)
	if(input == READ_RIGHT)
		animate(textright, alpha = 255, time = 5, easing = EASE_IN)
		textleft.alpha = 0
	if(input == READ_LEFT)
		textright.alpha = 0
		animate(textleft, alpha = 255, time = 5, easing = EASE_IN)
	if(input == READ_BOTH)
		animate(textleft, alpha = 255, time = 5, easing = EASE_IN)
		animate(textright, alpha = 255, time = 5, easing = EASE_IN)

/atom/movable/screen/readtext
	name = ""
	icon = null
	icon_state = ""
	screen_loc = "5,5"
	layer = HUD_LAYER+0.02
	plane = HUD_PLANE

/atom/movable/screen/area_text
	icon = null
	icon_state = ""
	name = ""
	screen_loc = "5,5"
	layer = HUD_LAYER+0.02
	plane = HUD_PLANE
	alpha = 0
	var/reading

/atom/movable/screen/daynight
	icon = 'icons/time.dmi'
	icon_state = ""
	screen_loc = "EAST-2:-14,CENTER-6:16"

/atom/movable/screen/daynight/New(client/C) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()
	icon_state = GLOB.tod
