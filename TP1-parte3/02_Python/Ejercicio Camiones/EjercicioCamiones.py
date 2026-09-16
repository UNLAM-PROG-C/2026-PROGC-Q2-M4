import threading
import random
import time

viajesDeBsAFernandez = 20
cantidadDeCamiones = 10
escala = 0.05
tiempoDeViajeMinimo = 18
tiempoDeViajeMaximo = 24
tiempoDeCargaYDescarga = 2
tiempoDeCombustible = 1
viajesRestantes = viajesDeBsAFernandez

#semaforos para controlar el acceso a las zonas de carga y descarga, 
# y a los surtidores de diesel
zonaCargaBuenosAires = threading.Semaphore(1)
zonaCargaFernandez = threading.Semaphore(1)
zonaDescargaFernandez = threading.Semaphore(1)
zonaDescargaBuenosAires = threading.Semaphore(1)
surtidoresDiesel = threading.Semaphore(2)
candadoViajes = threading.Lock()

def generarTiempoDeViaje():
    return random.uniform(tiempoDeViajeMinimo, tiempoDeViajeMaximo)

def esperarHoras(horas):
    time.sleep(horas * escala)

def obtenerViaje():
    global viajesRestantes

    with candadoViajes:
        if viajesRestantes == 0:
            return None

        numeroViaje = viajesDeBsAFernandez - viajesRestantes + 1
        viajesRestantes -= 1
        return numeroViaje

def tareaCamion(numero):
    while True:
        viaje = obtenerViaje()
        if viaje is None:
            break #se terminaron los viajes, el hilo termina.

        print(f"Camión {numero} esperando para cargar en Buenos Aires")
        zonaCargaBuenosAires.acquire()
        print(f"Camión {numero} cargando en Buenos Aires")
        esperarHoras(tiempoDeCargaYDescarga)  # Simula el tiempo de carga
        zonaCargaBuenosAires.release()
        print(f"Camión {numero} ha terminado de cargar en Buenos Aires")

        print(f"Camión {numero} viajando a Fernández")
        esperarHoras(generarTiempoDeViaje())  # Simula el tiempo de viaje

        print(f"Camión {numero} esperando para descargar en Fernández")
        zonaDescargaFernandez.acquire()
        print(f"Camión {numero} descargando en Fernández")
        esperarHoras(tiempoDeCargaYDescarga)  # Simula el tiempo de descarga
        zonaDescargaFernandez.release()
        print(f"Camión {numero} ha terminado de descargar en Fernández")
        
        print(f"Camión {numero} esperando para cargar en Fernández")
        zonaCargaFernandez.acquire()
        print(f"Camión {numero} cargando en Fernández")
        esperarHoras(tiempoDeCargaYDescarga)  # Simula el tiempo de carga
        zonaCargaFernandez.release()
        print(f"Camión {numero} ha terminado de cargar en Fernández")

        print(f"Camión {numero} esperando para surtir diesel")
        surtidoresDiesel.acquire()
        print(f"Camión {numero} surtiendo diesel")
        esperarHoras(tiempoDeCombustible)  # Simula el tiempo de surtido
        surtidoresDiesel.release()
        print(f"Camión {numero} ha terminado de surtir diesel")

        print(f"Camión {numero} viajando a Buenos Aires")
        esperarHoras(generarTiempoDeViaje())  # Simula el tiempo de viaje

        print(f"Camión {numero} esperando para descargar en Buenos Aires")
        zonaDescargaBuenosAires.acquire()
        print(f"Camión {numero} descargando en Buenos Aires")
        esperarHoras(tiempoDeCargaYDescarga)  # Simula el tiempo de descarga
        zonaDescargaBuenosAires.release()
        print(f"Camión {numero} ha terminado de descargar en Buenos Aires")
        print(f"Camión {numero} ha completado el viaje {viaje + 1} de {viajesDeBsAFernandez}")
        


    
#ejecucion del programa
hilos = []
tiempoInicio = time.time()
for numero in range(cantidadDeCamiones):
    hilo = threading.Thread(
        target=tareaCamion,
        args=(numero,)
    )
    hilos.append(hilo)
    hilo.start()

for hilo in hilos:
    hilo.join()

tiempoFinal = time.time()
tiempoTotalHoras = (tiempoFinal - tiempoInicio) / escala
print(f"Tiempo total de simulacion: {tiempoTotalHoras / 24:.2f} dias")

