"""Consumer/writer thread: operators that move packages into the inventory."""

import logging
import queue
import threading

import config
from core.inventory import Inventory
from core.package import Package
from workers.base import BaseWorker

logger = logging.getLogger(__name__)


class Operator(BaseWorker):
  """Takes packages from the dock queue and registers them in inventory."""

  def __init__(
      self,
      name: str,
      dock: "queue.Queue[Package]",
      inventory: Inventory,
      stop_event: threading.Event,
      processing_seconds: float = config.OPERATOR_PROCESSING_SECONDS,
  ) -> None:
    super().__init__(name=name, stop_event=stop_event)
    self._dock = dock
    self._inventory = inventory
    self._processing_seconds = processing_seconds

  def _step(self) -> None:
    """Processes one package, or returns on timeout to re-check shutdown."""
    try:
      package = self._dock.get(timeout=config.QUEUE_TIMEOUT_SECONDS)
    except queue.Empty:
      return
    try:
      self._stop_event.wait(self._processing_seconds)
      self._inventory.register(package)
      logger.debug("Registered %s", package)
    finally:
      self._dock.task_done()
