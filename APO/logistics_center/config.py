"""Centralized simulation constants (no magic numbers in the logic)."""

from typing import Final

TRUCK_COUNT: Final[int] = 2
OPERATOR_COUNT: Final[int] = 3

QUEUE_MAX_SIZE: Final[int] = 50
QUEUE_TIMEOUT_SECONDS: Final[float] = 0.5
JOIN_TIMEOUT_SECONDS: Final[float] = 5.0
MAIN_LOOP_WAIT_SECONDS: Final[float] = 0.5

TRUCK_ARRIVAL_INTERVAL_SECONDS: Final[float] = 1.0
MIN_PACKAGES_PER_BATCH: Final[int] = 3
MAX_PACKAGES_PER_BATCH: Final[int] = 8
MIN_UNITS_PER_PACKAGE: Final[int] = 1
MAX_UNITS_PER_PACKAGE: Final[int] = 10

OPERATOR_PROCESSING_SECONDS: Final[float] = 0.2

PRODUCT_SKUS: Final[tuple[str, ...]] = ("SKU-A", "SKU-B", "SKU-C", "SKU-D")

LOG_FORMAT: Final[str] = "%(asctime)s [%(threadName)-12s] %(levelname)s %(message)s"
