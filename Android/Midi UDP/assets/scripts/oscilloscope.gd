extends Line2D

@export var bus_name: String = "Master"
@export var amplitude: float = 400.0
@export var buffer_size: int = 250 
@export var trigger_threshold: float = 0.01

# --- NUEVA VARIABLE DE ESCALADO X ---
# 1.0 = Normal (1 muestra por punto)
# 5.0 = Zoom Out (Ver 5 veces más ondas en el mismo espacio)
@export var x_scale: float = 1.0 

var effect: AudioEffectCapture
var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	effect = AudioServer.get_bus_effect(bus_index, 0)
	
	points = []
	for i in range(buffer_size):
		add_point(Vector2(i * (800.0 / buffer_size), 0))

func _process(_delta):
	if not effect: return
	
	# Calculamos cuántos datos necesitamos según el escalado
	var needed_samples = int(buffer_size * x_scale)
	var chunk = effect.get_buffer(effect.get_frames_available())
	
	# Si no hay suficientes muestras para el zoom actual, esperamos al siguiente frame
	if chunk.size() < needed_samples: return

	# --- LÓGICA DE TRIGGERING ---
	var trigger_index = 0
	# Buscamos solo en la parte inicial del buffer para dejar espacio al dibujo
	var search_range = chunk.size() - needed_samples
	
	for i in range(1, search_range):
		var val_prev = (chunk[i-1].x + chunk[i-1].y) / 2.0
		var val_curr = (chunk[i].x + chunk[i].y) / 2.0
		
		if val_prev <= 0 and val_curr > 0 and val_curr > trigger_threshold:
			trigger_index = i
			break 
	
	# --- DIBUJO CON ESCALADO X ---
	for i in range(buffer_size):
		# Mapeamos el punto i al buffer usando x_scale como multiplicador
		var sample_idx = trigger_index + int(i * x_scale)
		
		if sample_idx < chunk.size():
			var sample = chunk[sample_idx]
			var value = (sample.x + sample.y) / 2.0
			
			# El dibujo mantiene su ancho de 800.0, pero los datos internos están comprimidos
			set_point_position(i, Vector2(i * (800.0 / buffer_size), value * amplitude))
		else:
			set_point_position(i, Vector2(i * (800.0 / buffer_size), 0))
