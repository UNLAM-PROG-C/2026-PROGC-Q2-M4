"""Producer thread: trucks that unload package batches into the dock queue."""

import itertools
import logging
import queue
import random
import threading

import config
from core.package import Package
from workers.base import BaseWorker

logger = logging.getLogger(__name__)


class Truck(BaseWorker):
  """Periodically arrives and enqueues a batch of packages."""

  def __init__(
      self,
      name: str,
      dock: "queue.Queue[Package]",
      stop_event: threading.Event,
      rng: random.Random | None = None,
  ) -> None:
    super().__init__(name=name, stop_event=stop_event)
    self._dock = dock
    self._rng = rng or random.Random()
    self._batch_counter = itertools.count(start=1)

  def _step(self) -> None:
    """Unloads one batch, then waits (interruptibly) for the next arrival."""
    batch = self._build_batch()
    delivered = sum(1 for package in batch if self._enqueue(package))
    logger.info("Delivered %d/%d packages", delivered, len(batch))
    self._stop_event.wait(config.TRUCK_ARRIVAL_INTERVAL_SECONDS)

  def _build_batch(self) -> list[Package]:
    """Creates a random batch of packages."""
    batch_id = f"{self.name}-{next(self._batch_counter)}"
    size = self._rng.randint(
        config.MIN_PACKAGES_PER_BATCH, config.MAX_PACKAGES_PER_BATCH)
    return [self._build_package(batch_id) for _ in range(size)]

  def _build_package(self, batch_id: str) -> Package:
    """Creates a single random package for the given batch."""
    return Package(
        sku=self._rng.choice(config.PRODUCT_SKUS),
        units=self._rng.randint(
            config.MIN_UNITS_PER_PACKAGE, config.MAX_UNITS_PER_PACKAGE),
        batch_id=batch_id,
    )

  def _enqueue(self, package: Package) -> bool:
    """Blocks on a full queue with timeouts until enqueued or stopped.

    Returns:
      True if the package was enqueued, False if shutdown was requested.
    """
    while not self._stop_event.is_set():
      try:
        self._dock.put(package, timeout=config.QUEUE_TIMEOUT_SECONDS)
        return True
      except queue.Full:
        continue
    return False
