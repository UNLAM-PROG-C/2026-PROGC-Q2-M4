"""Simulates n Mortal Kombat tournaments concurrently using m threads."""
import argparse
import threading
import time

from fighter import Fighter
from tournament import Tournament

_FIGHTERS = [
    Fighter("Liu Kang", 100, 25, 10, 8, 0.20, 0.15),
    Fighter("Kung Lao", 95, 26, 8, 9, 0.25, 0.10),
    Fighter("Johnny Cage", 110, 22, 12, 7, 0.15, 0.20),
    Fighter("Reptile", 90, 24, 9, 10, 0.20, 0.25),
    Fighter("Sub-Zero", 105, 23, 14, 6, 0.10, 0.25),
    Fighter("Shang Tsung", 85, 30, 5, 8, 0.25, 0.05),
    Fighter("Kitana", 85, 27, 7, 10, 0.20, 0.15),
    Fighter("Jax", 120, 20, 15, 4, 0.10, 0.25),
    Fighter("Mileena", 90, 28, 6, 9, 0.25, 0.10),
    Fighter("Baraka", 115, 29, 8, 5, 0.25, 0.05),
    Fighter("Scorpion", 100, 26, 11, 7, 0.20, 0.15),
    Fighter("Raiden", 110, 24, 10, 8, 0.15, 0.20),
]


class Results:
    """Accumulates the results of the tournaments run by a single thread.

    Attributes:
        wins_dict: Maps each fighter to a [fight_wins, championships] pair.
        total_turns: The total number of fight turns simulated.
    """

    def __init__(self) -> None:
        self.wins_dict = {fighter: [0, 0] for fighter in _FIGHTERS}
        self.total_turns = 0

    def calculate_results(self, tournament: Tournament) -> None:
        """Updates the accumulated results with a finished tournament.

        Args:
            tournament: A tournament that has already finished.
        """
        self.wins_dict[tournament.winner][1] += 1
        for fight in tournament.fights:
            self.wins_dict[fight.winner][0] += 1
            self.total_turns += fight.total_turns

    def show_results(self) -> None:
        """Prints the accumulated wins and championships per fighter."""
        for fighter, result in self.wins_dict.items():
            print(f"Fighter: {fighter.name} - Total Wins: {result[0]} - "
                  f"Championships: {result[1]}")


def simulate(tournament_count: int) -> None:
    """Simulates a number of tournaments and prints the results.

    Args:
        tournament_count: How many tournaments to simulate.
    """
    results = Results()
    for _ in range(tournament_count):
        tournament = Tournament(_FIGHTERS)
        tournament.start()
        results.calculate_results(tournament)
    results.show_results()


def main(args: argparse.Namespace) -> None:
    """Runs the configured number of tournaments across several threads.

    Args:
        args: Parsed command-line arguments with `tournaments` and
            `threads`.
    """
    tournaments_per_thread = args.tournaments // args.threads
    threads = [
        threading.Thread(target=simulate, args=(tournaments_per_thread,))
        for _ in range(args.threads)
    ]

    start_time = time.perf_counter()
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    end_time = time.perf_counter()

    execution_time = end_time - start_time
    print(f"Execution time: {execution_time:.6f} seconds")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="MortalKombat",
        description="A script that simulates n tournaments with m threads.")
    parser.add_argument(
        "tournaments", type=int, default=100000,
        help="Number of tournaments to simulate")
    parser.add_argument(
        "-t", "--threads", type=int, default=4,
        help="Number of threads to use")
    main(parser.parse_args())
