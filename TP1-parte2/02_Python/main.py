from tournament import Tournament
from fighter import Fighter
import threading
import argparse
import time

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
    Fighter("Raiden", 110, 24, 10, 8, 0.15, 0.20)
]

class Results:
    wins_dict = {}
    def __init__(self) -> None:
        for fighter in _FIGHTERS:
            self.wins_dict.update({fighter: [0, 0]})
        self.total_turns = 0

    def calculate_results(self, tournament: Tournament):
        self.wins_dict[tournament.winner][1] += 1
        for fight in tournament.fights:
            self.wins_dict[fight.winner][0] += 1
            self.total_turns += fight.total_turns

    def show_results(self):
        for fighter, result  in self.wins_dict.items():
            print(f'Fighter: {fighter.name} - Total Wins: {result[0]} - Championships: {result[1]}')

    

def simulate(kTournaments):
    results = Results()
    for _ in range(kTournaments):
        tournament = Tournament(_FIGHTERS)
        tournament.start()
        results.calculate_results(tournament)
    results.show_results()
def main(args):
    threads = []
    start_time = time.perf_counter()
    kTournaments = args.tournaments//args.threads
    for _ in range(args.threads):
        t = threading.Thread(target=simulate, args=(kTournaments,))
        threads.append(t)
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    end_time = time.perf_counter()
    execution_time = end_time - start_time
    print(f"Execution time: {execution_time:.6f} seconds")
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='MortalKombat', description="A script that simulates n tournaments with m threads.")
    parser.add_argument("tournaments", type=int, default=100000, help="Number of tournaments to simulate")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads to use")
    args = parser.parse_args()
    main(args)
