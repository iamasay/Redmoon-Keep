/datum/crafting_recipe/roguetown/alchemy
	abstract_type = /datum/crafting_recipe/roguetown/alchemy
	req_table = FALSE
	tools = list(/obj/item/reagent_containers/glass/alembic)
	verbage_simple = "mix"
	skillcraft = /datum/skill/misc/alchemy
	subtype_reqs = TRUE

/datum/crafting_recipe/roguetown/alchemy/thermometer
	name = "Thermoscope - (bottle, mercury; METAL ALEMBIC; COMPETENT)"
	result = list(/obj/item/thermometer)
	reqs = list(/obj/item/reagent_containers/glass/bottle = 1, /datum/reagent/mercury = 5)
	skill_level = 2

/datum/crafting_recipe/roguetown/alchemy/bbomb
	name = "Bottle bomb - (bottle, 2 ash, coal, cloth; METAL ALEMBIC; COMPETENT)"
	result = list(/obj/item/bomb)
	reqs = list(/obj/item/reagent_containers/glass/bottle = 1, /obj/item/ash = 2, /obj/item/rogueore/coal = 1, /obj/item/natural/cloth = 1)
	skill_level = 2

