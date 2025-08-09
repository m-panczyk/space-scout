extends Resource
class_name JobsDefinitions

class Job:
	var name: String
	var description: String
	var effect_function: Callable
	var cost: int

	func _init(_name: String, _desc: String, _cost: int, _effect: Callable):
		name = _name
		description = _desc
		cost = _cost
		effect_function = _effect

static var jobs: Dictionary = {}

static func _static_init():
	_initialize_jobs()

static func _initialize_jobs():
	# Hull upgrade
	jobs["Hull"] = Job.new(
		"Ulepszenie Kadłuba",
		"[b]Ulepszenie Kadłuba[/b]\n[color=#4CAF50][b]+1 Wytrzymałość[/b][/color]\nWzmocniona konstrukcja pancerza i struktur nośnych statku zwiększa jego odporność na uszkodzenia bojowe.",
		30,
		func(): _apply_hull_upgrade()
	)
	
	# Energy storage upgrade
	jobs["EnergyStore"] = Job.new(
		"Rozbudowa Magazynu Energii",
		"[b]Rozbudowa Magazynu Energii[/b]\n[color=#2196F3][b]+5 Magazyn energii[/b][/color]\nDodatkowe kondensatory i systemy przechowywania energii pozwalają na dłuższą pracę systemów pokładowych.",
		25,
		func(): _apply_energy_store_upgrade()
	)
	
	# Energy production upgrade
	jobs["EnergyProduction"] = Job.new(
		"Rozbudowa Reaktora",
		"[b]Rozbudowa Reaktora[/b]\n[color=#FF9800][b]+1/s Energii[/b][/color]\nModernizacja rdzenia reaktora zwiększa wydajność produkcji energii dla wszystkich systemów statku.",
		40,
		func(): _apply_energy_production_upgrade()
	)
	
	# Speed upgrade
	jobs["Speed"] = Job.new(
		"Ulepszenie Silników",
		"[b]Ulepszenie Silników[/b]\n[color=#E91E63][b]+10 Prędkość[/b][/color]\nOptymalizacja układów napędowych i systemów sterowania znacząco poprawia manewrowość i szybkość statku.",
		35,
		func(): _apply_speed_upgrade()
	)
	
	# Weapon efficiency upgrade
	jobs["Consumption"] = Job.new(
		"Optymalizacja Działa",
		"[b]Optymalizacja Działa[/b]\n[color=#9C27B0][b]-1 Koszt Energii[/b][/color]\nZaawansowane systemy zarządzania mocą redukują zużycie energii przez systemy uzbrojenia.",
		30,
		func(): _apply_weapon_upgrade()
	)

# Effect functions that use EventBus for loose coupling
static func _apply_hull_upgrade():
	EventBus.emit("upgrade_hull", 1)

static func _apply_energy_store_upgrade():
	EventBus.emit("upgrade_energy_max", 5)

static func _apply_energy_production_upgrade():
	EventBus.emit("upgrade_energy_production", 1)

static func _apply_speed_upgrade():
	EventBus.emit("upgrade_speed", 100)

static func _apply_weapon_upgrade():
	EventBus.emit("upgrade_weapon_efficiency", 2)

static func get_job(job_id: String) -> Job:
	return jobs.get(job_id)

static func get_all_jobs() -> Array[Job]:
	var job_array: Array[Job] = []
	for job in jobs.values():
		job_array.append(job)
	return job_array
