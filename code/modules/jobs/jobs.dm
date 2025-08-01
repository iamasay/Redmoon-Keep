GLOBAL_LIST_INIT(command_positions, list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"))


GLOBAL_LIST_INIT(engineering_positions, list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician"))


GLOBAL_LIST_INIT(medical_positions, list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Virologist",
	"Chemist"))


GLOBAL_LIST_INIT(science_positions, list(
	"Research Director",
	"Scientist",
	"Roboticist"))


GLOBAL_LIST_INIT(supply_positions, list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner"))


GLOBAL_LIST_INIT(civilian_positions, list(
	"Bartender",
	"Kek",
	"Cook",
	"Janitor",
	"Curator",
	"Lawyer",
	"Chaplain",
	"Clown",
	"Mime",
	"Assistant"))


GLOBAL_LIST_INIT(security_positions, list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer"))


GLOBAL_LIST_INIT(nonhuman_positions, list(
	"AI",
	"Cyborg",
	ROLE_PAI))

// FIRST POSITIONS SUCH AS DUKE OR HEAD BUTLER E.T.C. MUST ALWAYS STAY ON THE TOP OF THE LIST
GLOBAL_LIST_INIT(noble_positions, list(
	"Duke",
	"Duke Consort",
	"Heir",
	"Retinue Captain",
	"Royal Marshal",
	"Steward",
	"Knight",
))

GLOBAL_LIST_INIT(courtier_positions, list(
	"Head Butler",
	"Court Magos",
	"Court Physician",
	"Councillor",
	"Jester",
))

GLOBAL_LIST_INIT(garrison_positions, list(
	"Town Sheriff",
	"Watchman",
	"Warden",
	"Gatemaster",
	"Vanguard",
	"Veteran",
	"Man at Arms",
	"Dungeoneer",
))

GLOBAL_LIST_INIT(church_positions, list(
	"Priest",
	"Acolyte",
	"Mortician",
	"Templar",
	"Druid",
	"Hospitaller",
))

GLOBAL_LIST_INIT(inquisition_positions, list(
	"Inquisitor",
	"Confessor",
))

GLOBAL_LIST_INIT(yeoman_positions, list(
	"Mayor",
	"Merchant",
	"Scholar",
	"Barkeep",
	"Guild Smith",
	"Seamster",
	"Alchemist",
	"Architect",
	"Artificer",
	"Scribe",
	"Harbormaster",
	"Longshoreman",
	"Guild mage", // REDMOON CHANGE - Вместо учеников мага теперь Гильдейские маги. 04.05.25 Corde50
))

GLOBAL_LIST_INIT(peasant_positions, list(
	"Soilson",
	"Butcher",
	"Cook",
	"Miner",
	"Hunter",
	"Fisher",
	"Lumberjack",
	"Towner",
	"Nightmaster",
	"Henchman",
	"Nightswain",
	"Docker",
	"Prisoner",
	"Beggar",
	"Stowaway",
	"Lunatic",
	"Town Seelie",
))

GLOBAL_LIST_INIT(mercenary_positions, list(
	"Guild Clerk",
	"Mercenary",
))

GLOBAL_LIST_INIT(youngfolk_positions, list(
	"Squire",
	"Clerk",
	"Servant",
	"Smithy Apprentice",
	"Novitiate",
	"Shophand",
))

GLOBAL_LIST_INIT(foreigner_positions, list(
	"Adventurer",
	"Refugee",
	"Migrant",
	"Bandit",
))

GLOBAL_LIST_INIT(roguewar_positions, list(
	"Refugee",
))

GLOBAL_LIST_INIT(goblin_positions, list(
	"Goblin Chief",
	"Goblin Cook",
	"Goblin Guard",
	"Goblin Rabble",
	"Goblin Smith",
	"Goblin Shaman",
))

GLOBAL_LIST_INIT(tribal_positions, list(
	"Tribal Chief",
	"Tribal Guard",
	"Tribal Tinkerer",
	"Tribal Seer",
	"Tribal Lackey",
	"Tribal Caveling",
))

GLOBAL_LIST_INIT(roguefight_positions, list(
	"Red Captain",
	"Red Caster",
	"Red Ranger",
	"Red Fighter",
	"Green Captain",
	"Green Caster",
	"Green Ranger",
	"Green Fighter",
))

GLOBAL_LIST_INIT(test_positions, list(
	"Tester",
))

GLOBAL_LIST_INIT(job_assignment_order, get_job_assignment_order())

/proc/get_job_assignment_order()
	var/list/sorting_order = list()
	sorting_order += GLOB.noble_positions
	sorting_order += GLOB.courtier_positions
	sorting_order += GLOB.garrison_positions
	sorting_order += GLOB.church_positions
	sorting_order += GLOB.inquisition_positions
	sorting_order += GLOB.yeoman_positions
	sorting_order += GLOB.peasant_positions
	sorting_order += GLOB.youngfolk_positions
	sorting_order += GLOB.mercenary_positions
	sorting_order += GLOB.foreigner_positions
	return sorting_order

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_CREW = list("titles" = peasant_positions | command_positions | engineering_positions | medical_positions | science_positions | supply_positions | security_positions | civilian_positions | list("AI","Cyborg")), // crew positions
	EXP_TYPE_COMMAND = list("titles" = command_positions),
	EXP_TYPE_ENGINEERING = list("titles" = engineering_positions),
	EXP_TYPE_MEDICAL = list("titles" = medical_positions),
	EXP_TYPE_SCIENCE = list("titles" = science_positions),
	EXP_TYPE_SUPPLY = list("titles" = supply_positions),
	EXP_TYPE_SECURITY = list("titles" = security_positions),
	EXP_TYPE_SILICON = list("titles" = list("AI","Cyborg")),
	EXP_TYPE_SERVICE = list("titles" = civilian_positions),
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list("Lifebringer","Ash Walker","Exile","Servant Golem","Free Golem","Hermit","Translocated Vet","Escaped Prisoner","Hotel Staff","SuperFriend","Space Syndicate","Ancient Crew","Space Doctor","Space Bartender","Beach Bum","Skeleton","Zombie","Space Bar Patron","Lavaland Syndicate","Ghost Role"), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)

/proc/guest_jobbans(job)
	return ((job in GLOB.command_positions) || (job in GLOB.nonhuman_positions) || (job in GLOB.security_positions))



//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(job_title)
	if(!job_title)
		return list()

	for(var/datum/job/J in SSjob.occupations)
		if(J.title == job_title)
			return J.department_head //this is a list

/proc/get_full_job_name(job)
	var/static/regex/cap_expand = new("cap(?!tain)")
	var/static/regex/cmo_expand = new("cmo")
	var/static/regex/hos_expand = new("hos")
	var/static/regex/hop_expand = new("hop")
	var/static/regex/rd_expand = new("rd")
	var/static/regex/ce_expand = new("ce")
	var/static/regex/qm_expand = new("qm")
	var/static/regex/sec_expand = new("(?<!security )officer")
	var/static/regex/engi_expand = new("(?<!station )engineer")
	var/static/regex/atmos_expand = new("atmos tech")
	var/static/regex/doc_expand = new("(?<!medical )doctor|medic(?!al)")
	var/static/regex/mine_expand = new("(?<!shaft )miner")
	var/static/regex/chef_expand = new("chef")
	var/static/regex/borg_expand = new("(?<!cy)borg")

	job = lowertext(job)
	job = cap_expand.Replace(job, "captain")
	job = cmo_expand.Replace(job, "chief medical officer")
	job = hos_expand.Replace(job, "head of security")
	job = hop_expand.Replace(job, "head of personnel")
	job = rd_expand.Replace(job, "research director")
	job = ce_expand.Replace(job, "chief engineer")
	job = qm_expand.Replace(job, "quartermaster")
	job = sec_expand.Replace(job, "security officer")
	job = engi_expand.Replace(job, "station engineer")
	job = atmos_expand.Replace(job, "atmospheric technician")
	job = doc_expand.Replace(job, "medical doctor")
	job = mine_expand.Replace(job, "shaft miner")
	job = chef_expand.Replace(job, "cook")
	job = borg_expand.Replace(job, "cyborg")
	return job
