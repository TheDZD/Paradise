/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")


/obj/item/weapon/banhammer/suicide_act(mob/user)
		to_chat(viewers(user), "<span class='suicide'>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</span>")
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='suicide'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50

/obj/item/weapon/claymore/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(BRUTELOSS)

/obj/item/weapon/claymore/ceremonial
	name = "ceremonial claymore"
	desc = "An engraved and fancy version of the claymore. It appears to be less sharp than it's more functional cousin."
	force = 20


/obj/item/weapon/claymore/highlander
	desc = "<b><i>THERE CAN BE ONLY ONE, AND IT WILL BE YOU!!!</i></b>\nActivate it in your hand to point to the nearest victim."
	block_chance = 0
	attack_verb = list("brutalized", "eviscerated", "disemboweled", "hacked", "carved", "cleaved", "gored")
	var/notches = 0 //killcount
	var/announced = FALSE //whether or not last man standing has been announced
	var/static/highlander_claymores = 0

/obj/item/weapon/claymore/highlander/New()
	..()
	processing_objects += src
	highlander_claymores++

/obj/item/weapon/claymore/highlander/Destroy()
	processing_objects -= src
	highlander_claymores--
	return ..()

/obj/item/weapon/claymore/highlander/process()
	if(isliving(loc))
		var/mob/living/L = loc
		if(L.stat != DEAD)
			if(announced || highlander_claymores > 1)
				return
			announced = TRUE
			L.revive()
			to_chat(world, "<span class='userdanger'>[L.real_name] IS THE ONLY ONE LEFT STANDING!</span>")
			world << sound('sound/misc/highlander_only_one.ogg')
			to_chat(L, "<span class='notice'>YOU ARE THE ONLY ONE LEFT STANDING!</span>")
		else
			L.dust()

/obj/item/weapon/claymore/highlander/pickup(mob/living/user)
	to_chat(user, "<span class='notice'>The power of Scotland protects you! You are shielded from all stuns and knockdowns.</span>")

	var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH //shameless copypasta from hulk, need some better way to make people stun-immune on the long term.
	user.status_flags &= ~status

/obj/item/weapon/claymore/highlander/dropped(mob/living/user)
	to_chat(user, "<span class='danger'>The power of Scotland fades away! You are no longer shielded from stuns.</span>")

	var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH //see above comment
	user.status_flags |= status

/obj/item/weapon/claymore/highlander/examine(mob/user)
	..()
	to_chat(user, "It has [!notches ? "nothing" : "[notches] notches"] scratched into the blade.")

/obj/item/weapon/claymore/highlander/attack(mob/living/target, mob/living/user)
	var/old_target_health = target.health //If stat updates are ever made instant (IE: not in Life), this should be changed to check stat, not health.
	. = ..()
	if(target && target.mind && target.health <= config.health_threshold_dead && old_target_health >= config.health_threshold_dead)
		user.revive()
		add_notch(user)
		target.visible_message("<span class='warning'>[target] crumbles to dust beneath [user]'s blows!</span>", "<span class='userdanger'>As you fall, your body crumbles to dust!</span>")
		target.dust()

/obj/item/weapon/claymore/highlander/attack_self(mob/living/user)
	var/closest_victim
	var/closest_distance = 255
	for(var/mob/living/carbon/human/H in player_list - user)
		if(H.client && (!closest_victim || get_dist(user, closest_victim) < closest_distance))
			closest_victim = H
	if(!closest_victim)
		to_chat(user, "<span class='warning'>[src] thrums for a moment and falls dark. Perhaps there's nobody nearby.</span>")
	else
		to_chat(user, "<span class='danger'>[src] thrums and points to the [dir2text(get_dir(user, closest_victim))].</span>")

/obj/item/weapon/claymore/highlander/IsReflect()
	return 1 //YOU THINK YOUR PUNY LASERS CAN STOP ME?

/obj/item/weapon/claymore/highlander/proc/add_notch(mob/living/user)
	notches++
	force++
	var/new_name = name
	switch(notches)
		if(1)
			to_chat(user, "<span class='notice'>Your first kill - hopefully one of many. You scratch a notch into [src]'s blade.</span>")
			to_chat(user, "<span class='warning'>You feel your fallen foe's soul entering your blade, restoring your wounds!</span>")
			new_name = "notched claymore"
		if(2)
			to_chat(user, "<span class='notice'>Another falls before you. Another soul fuses with your own. Another notch in the blade.</span>")
			new_name = "double-notched claymore"
			color = rgb(255, 235, 235)
		if(3)
			to_chat(user, "<span class='notice'>You're beginning to</span> <span class='danger'><b>relish</b> the <b>thrill</b> of <b>battle.</b></span>")
			new_name = "triple-notched claymore"
			color = rgb(255, 215, 215)
		if(4)
			to_chat(user, "<span class='notice'>You've lost count of</span> <span class='boldannounce'>how many you've killed.</span>")
			new_name = "many-notched claymore"
			color = rgb(255, 195, 195)
		if(5)
			to_chat(user, "<span class='boldannounce'>Five voices now echo in your mind, cheering the slaughter.</span>")
			new_name = "battle-tested claymore"
			color = rgb(255, 175, 175)
		if(6)
			to_chat(user, "<span class='boldannounce'>Is this what the vikings felt like? Visions of glory fill your head as you slay your sixth foe.</span>")
			new_name = "battle-scarred claymore"
			color = rgb(255, 155, 155)
		if(7)
			to_chat(user, "<span class='boldannounce'>Kill. Butcher. <i>Conquer.</i></span>")
			new_name = "vicious claymore"
			color = rgb(255, 135, 135)
		if(8)
			to_chat(user, "<span class='userdanger'>IT NEVER GETS OLD. THE <i>SCREAMING</i>. THE <i>BLOOD</i> AS IT <i>SPRAYS</i> ACROSS YOUR <i>FACE.</i></span>")
			new_name = "bloodthirsty claymore"
			color = rgb(255, 115, 115)
		if(9)
			to_chat(user, "<span class='userdanger'>ANOTHER ONE FALLS TO YOUR BLOWS. ANOTHER WEAKLING UNFIT TO LIVE.</span>")
			new_name = "gore-stained claymore"
			color = rgb(255, 95, 95)
		if(10)
			user.visible_message("<span class='warning'>[user]'s eyes light up with a vengeful fire!</span>", \
			"<span class='userdanger'>YOU FEEL THE POWER OF VALHALLA FLOWING THROUGH YOU! <i>THERE CAN BE ONLY ONE!!!</i></span>")
			user.update_icons()
			new_name = "GORE-DRENCHED CLAYMORE OF [pick("THE WHIMSICAL SLAUGHTER", "A THOUSAND SLAUGHTERED CATTLE", "GLORY AND VALHALLA", "ANNIHILATION", "OBLITERATION")]"
			icon_state = "claymore_blazing"
			item_state = "cultblade"
			color = initial(color)

	name = new_name
	playsound(user, 'sound/items/Screwdriver2.ogg', 50, 1)

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50

/obj/item/weapon/katana/cursed
	slot_flags = null

/obj/item/weapon/katana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
	return(BRUTELOSS)

/obj/item/weapon/harpoon
	name = "harpoon"
	sharp = 1
	edge = 0
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = 3
	attack_verb = list("jabbed","stabbed","ripped")

obj/item/weapon/wirerod
	name = "Wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = CONDUCT
	force = 9
	throwforce = 10
	w_class = 3
	materials = list(MAT_METAL=1000)
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")

obj/item/weapon/wirerod/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/weapon/shard))
		var/obj/item/weapon/twohanded/spear/S = new /obj/item/weapon/twohanded/spear

		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.unEquip(I)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/weapon/wirecutters))
		var/obj/item/weapon/melee/baton/cattleprod/P = new /obj/item/weapon/melee/baton/cattleprod

		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.unEquip(I)

		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>")
		qdel(I)
		qdel(src)


/obj/item/weapon/spear/kidan
	icon_state = "kidanspear"
	name = "Kidan spear"
	desc = "A one-handed spear brought over from the Kidan homeworld."
	icon_state = "kidanspear"
	item_state = "kidanspear"
	force = 10
	throwforce = 15
