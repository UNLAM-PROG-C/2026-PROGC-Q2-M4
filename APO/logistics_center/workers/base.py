"""Abstract base for every simulation thread."""

import logging
import threading
from abc import ABC, abstractmethod

logger = logging.getLogger(__name__)


class BaseWorker(threading.Thread, ABC):
  """Thread whose lifecycle is driven by a shared stop event.

  Template Method pattern: `run()` owns the loop, the shutdown check and the
  global error handling; subclasses only implement one unit of work in
  `_step()`. Any unexpected exception is logged, stored and propagated as a
  shutdown signal (fail-fast), so no thread ever dies silently.
  """

  def __init__(self, name: str, stop_event: threading.Event) -> None:
    super().__init__(name=name, daemon=False)
    self._stop_event = stop_event
    self._error: Exception | None = None

  @property
  def error(self) -> Exception | None:
    """The exception that terminated the thread, if any."""
    return self._error

  def run(self) -> None:
    """Runs `_step()` until shutdown is requested or a failure occurs."""
    logger.info("Started")
    try:
      while not self._should_stop():
        self._step()
    except Exception as exc:  # pylint: disable=broad-except
      self._error = exc
      logger.exception("Unhandled error, requesting global shutdown")
      self._stop_event.set()
    finally:
      self._on_stop()
      logger.info("Stopped")

  def _should_stop(self) -> bool:
    """Exit condition of the run loop. Subclasses may extend it."""
    return self._stop_event.is_set()

  @abstractmethod
  def _step(self) -> None:
    """Performs one bounded unit of work.

    Implementations must never block indefinitely: every blocking call needs
    a timeout so the stop event is re-checked periodically.
    """

  def _on_stop(self) -> None:
    """Hook for resource cleanup. Runs always, even after a failure."""
