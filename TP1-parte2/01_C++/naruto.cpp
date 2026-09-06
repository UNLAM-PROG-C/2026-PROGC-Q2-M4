#include <chrono>
#include <iostream>
#include <numeric>
#include <random>
#include <sstream>
#include <thread>
#include <vector>

namespace {

void EntrenarClon(int indice_clon, std::vector<int>& niveles_clones) {
  std::random_device fuente_semilla;
  std::mt19937 generador(fuente_semilla());
  std::uniform_int_distribution<int> dist_chakra(5, 10);
  std::uniform_int_distribution<int> dist_pausa_ms(100, 200);
  std::bernoulli_distribution dist_sube_nivel(0.5);

  int chakra = dist_chakra(generador);
  while (chakra-- > 0) {
    if (dist_sube_nivel(generador)) {
      ++niveles_clones[indice_clon];
    }
    std::this_thread::sleep_for(
        std::chrono::milliseconds(dist_pausa_ms(generador)));
  }
}

int Entrenar(int cantidad_clones) {
  std::vector<int> niveles_clones(cantidad_clones);
  {
    std::vector<std::jthread> clones;
    clones.reserve(cantidad_clones);
    for (int i = 0; i < cantidad_clones; ++i) {
      clones.emplace_back(EntrenarClon, i, std::ref(niveles_clones));
    }
  }
  return std::accumulate(niveles_clones.begin(), niveles_clones.end(), 0);
}

int ProcesarArgs(int argc, char* argv[]) {
  if (argc < 2) {
    std::cerr << "Falta argumento. Uso: " << argv[0] << " <cantidad_clones>\n";
    return -1;
  }
  std::stringstream ss(argv[1]);
  int value{};
  if (ss >> value) {
    return value;
  }
  std::cerr << "Error: '" << argv[1] << "' could not be parsed.\n";
  return -1;
}

}  // namespace

int main(int argc, char* argv[]) {
  const int cantidad_clones = ProcesarArgs(argc, argv);
  if (cantidad_clones != -1) {
    const auto inicio = std::chrono::steady_clock::now();
    const int nivel_alcanzado = Entrenar(cantidad_clones);
    const auto fin = std::chrono::steady_clock::now();
    const std::chrono::duration<double, std::milli> duracion = fin - inicio;
    std::cout << "Nivel alcanzado: " << nivel_alcanzado << "\n"
              << "Tiempo de ejecución: " << duracion.count() << " ms\n";
  }
  return 0;
}