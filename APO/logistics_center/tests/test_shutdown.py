"""Tests for the two-phase shutdown sequence in main."""

import queue
import threading
import unittest
from unittest import mock

import main
from core.inventory import Inventory
from core.package import Package
from workers.operator import Operator

OPERATOR_COUNT = 3
PACKAGE_COUNT = 20
NO_DELAY = 0.0
JOIN_TIMEOUT_SECONDS = 5.0


class ShutdownInterruptTest(unittest.TestCase):
  """A second Ctrl+C during the first phase must not strand the operators."""

  def setUp(self) -> None:
    self.stop_event = threading.Event()
    self.producers_finished = threading.Event()
    self.dock: "queue.Queue[Package]" = queue.Queue()
    for index in range(PACKAGE_COUNT):
      self.dock.put(Package(sku="SKU-A", units=1, batch_id=f"batch-{index}"))
    self.inventory = Inventory()
    self.operators = [
        Operator(f"Operator-{index}", self.dock, self.inventory,
                 self.stop_event, self.producers_finished,
                 processing_seconds=NO_DELAY)
        for index in range(OPERATOR_COUNT)]
    # Safety net: never leave non-daemon threads behind if the test fails.
    self.addCleanup(self._release_operators)

  def _release_operators(self) -> None:
    self.stop_event.set()
    self.producers_finished.set()
    for operator in self.operators:
      operator.join(JOIN_TIMEOUT_SECONDS)

  def test_interrupt_during_first_phase_still_drains_operators(self) -> None:
    for operator in self.operators:
      operator.start()
    # First Ctrl+C already happened: wait_for_shutdown set the stop event.
    self.stop_event.set()
    interrupted_worker = mock.Mock(name="Truck-1")
    interrupted_worker.join.side_effect = KeyboardInterrupt

    with self.assertRaises(KeyboardInterrupt):
      main.shutdown([interrupted_worker], self.operators,
                    self.producers_finished)

    self.assertTrue(self.producers_finished.is_set())
    for operator in self.operators:
      operator.join(JOIN_TIMEOUT_SECONDS)
    alive = [operator.name for operator in self.operators
             if operator.is_alive()]
    self.assertFalse(alive, f"Operators still running: {alive}")
    self.assertTrue(self.dock.empty())
    self.assertEqual(self.inventory.snapshot().packages_received,
                     PACKAGE_COUNT)


if __name__ == "__main__":
  unittest.main()
