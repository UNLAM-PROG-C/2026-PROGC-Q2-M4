"""Entry point: wires shared resources, starts workers, shuts down cleanly."""

import logging
import queue
import threading

import config
from core.inventory import Inventory
from core.package import Package
from workers.base import BaseWorker
from workers.operator import Operator
from workers.truck import Truck

logger = logging.getLogger("main")


def build_trucks(
    dock: "queue.Queue[Package]", stop_event: threading.Event) -> list[Truck]:
  """Creates the producer threads."""
  return [Truck(f"Truck-{index}", dock, stop_event)
          for index in range(1, config.TRUCK_COUNT + 1)]


def build_operators(
    dock: "queue.Queue[Package]",
    inventory: Inventory,
    stop_event: threading.Event,
) -> list[Operator]:
  """Creates the consumer/writer threads."""
  return [Operator(f"Operator-{index}", dock, inventory, stop_event)
          for index in range(1, config.OPERATOR_COUNT + 1)]


def wait_for_shutdown(stop_event: threading.Event) -> None:
  """Blocks the main thread until Ctrl+C or a worker requests shutdown.

  `wait()` with a timeout keeps the main thread responsive to SIGINT.
  """
  try:
    while not stop_event.wait(config.MAIN_LOOP_WAIT_SECONDS):
      pass
  except KeyboardInterrupt:
    logger.info("Ctrl+C received, requesting shutdown")
  finally:
    stop_event.set()


def join_all(workers: list[BaseWorker]) -> None:
  """Joins producers first, then consumers, each with a bounded timeout."""
  for worker in workers:
    worker.join(timeout=config.JOIN_TIMEOUT_SECONDS)
    if worker.is_alive():
      logger.warning("%s did not stop within timeout", worker.name)
    elif worker.error is not None:
      logger.error("%s failed: %r", worker.name, worker.error)


def report(inventory: Inventory, dock: "queue.Queue[Package]") -> None:
  """Logs the final state of the simulation."""
  snapshot = inventory.snapshot()
  logger.info("Final stock: %s", dict(snapshot.stock))
  logger.info("Packages registered: %d | units: %d | left in dock: %d",
              snapshot.packages_received, snapshot.units_received,
              dock.qsize())


def main() -> None:
  """Runs the logistics center simulation."""
  logging.basicConfig(level=logging.INFO, format=config.LOG_FORMAT)
  stop_event = threading.Event()
  dock: "queue.Queue[Package]" = queue.Queue(maxsize=config.QUEUE_MAX_SIZE)
  inventory = Inventory()
  workers: list[BaseWorker] = [
      *build_trucks(dock, stop_event),
      *build_operators(dock, inventory, stop_event),
  ]
  for worker in workers:
    worker.start()
  wait_for_shutdown(stop_event)
  join_all(workers)
  report(inventory, dock)


if __name__ == "__main__":
  main()
