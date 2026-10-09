"""Entry point: wires shared resources, starts workers, shuts down cleanly."""

import logging
import queue
import threading

import config
from core.inventory import Inventory
from core.package import Package
from ui.dashboard import Dashboard
from workers.base import BaseWorker
from workers.operator import Operator
from workers.supervisor import Supervisor
from workers.truck import Truck

logger = logging.getLogger("main")


def build_trucks(
    dock: "queue.Queue[Package]",
    stop_event: threading.Event,
    maintenance_event: threading.Event,
) -> list[Truck]:
  """Creates the producer threads."""
  return [Truck(f"Truck-{index}", dock, stop_event,
                maintenance_event=maintenance_event)
          for index in range(1, config.TRUCK_COUNT + 1)]


def build_operators(
    dock: "queue.Queue[Package]",
    inventory: Inventory,
    stop_event: threading.Event,
    producers_finished: threading.Event,
    maintenance_event: threading.Event,
) -> list[Operator]:
  """Creates the consumer/writer threads."""
  return [Operator(f"Operator-{index}", dock, inventory, stop_event,
                   producers_finished, maintenance_event=maintenance_event)
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


def join_all(workers: list[BaseWorker], timeout: float) -> None:
  """Joins the given workers, each with a bounded timeout."""
  for worker in workers:
    worker.join(timeout=timeout)
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


def shutdown(
    first_phase: list[BaseWorker],
    operators: list[Operator],
    producers_finished: threading.Event,
) -> None:
  """Two-phase shutdown: stop producers/readers, then drain the dock.

  Args:
    first_phase: Workers driven only by the stop event (trucks, dashboard,
      supervisor). Stopping the supervisor clears any active maintenance.
    operators: Consumers that keep running until the dock is empty.
    producers_finished: Signal that no more packages will be enqueued.
  """
  join_all(first_phase, config.JOIN_TIMEOUT_SECONDS)
  producers_finished.set()
  logger.info("Producers stopped, draining dock")
  join_all(operators, config.DRAIN_TIMEOUT_SECONDS)


def main() -> None:
  """Runs the logistics center simulation."""
  logging.basicConfig(level=logging.INFO, format=config.LOG_FORMAT)
  stop_event = threading.Event()
  producers_finished = threading.Event()
  maintenance_event = threading.Event()
  dock: "queue.Queue[Package]" = queue.Queue(maxsize=config.QUEUE_MAX_SIZE)
  inventory = Inventory()
  trucks = build_trucks(dock, stop_event, maintenance_event)
  operators = build_operators(dock, inventory, stop_event, producers_finished,
                              maintenance_event)
  dashboard = Dashboard("Dashboard", inventory, dock, stop_event)
  supervisor = Supervisor("Supervisor", stop_event, maintenance_event)
  first_phase: list[BaseWorker] = [*trucks, dashboard, supervisor]
  for worker in [*first_phase, *operators]:
    worker.start()
  wait_for_shutdown(stop_event)
  shutdown(first_phase, operators, producers_finished)
  report(inventory, dock)


if __name__ == "__main__":
  main()
