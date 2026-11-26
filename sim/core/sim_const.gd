class_name SimConst
extends RefCounted
## Konstanta sentral simulasi. Semua angka tuning di sini.

const TICKS_PER_DAY: int = 144
const SECONDS_PER_TICK: float = 0.25
const MAX_TICKS_PER_FRAME: int = 20

const HUNGER_DECAY: float = 0.35
const ENERGY_DECAY: float = 0.25
const ENERGY_DECAY_WORKING: float = 0.5

const STARVING_HEALTH_LOSS: float = 2.0
const HEALTH_REGEN_THRESHOLD: float = 50.0
const HEALTH_REGEN_RATE: float = 0.1

const NIGHT_START_HOUR: float = 21.0
const DAWN_START_HOUR: float = 5.0
const DUSK_START_HOUR: float = 19.0
const DAY_START_HOUR: float = 7.0

const EAT_HUNGER_RESTORE: float = 40.0
const SLEEP_ENERGY_RESTORE: float = 1.2
const WORK_FARM_FOOD_PRODUCED: int = 1
const WORK_FARM_DURATION: int = 6
const EAT_DURATION: int = 2
const SLEEP_DURATION: int = 48
const RECOVER_DURATION: int = 12
const RECOVER_HEALTH_RESTORE: float = 2.5

const INITIAL_GRANARY_FOOD: int = 20
const DEFAULT_GRANARY_CAPACITY: int = 500
const DEFAULT_AGENT_COUNT: int = 3
