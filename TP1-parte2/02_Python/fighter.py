"""
This module defines the classes and logic for fighters in the tournament.
"""
import random
from pydantic import BaseModel, Field


class FighterAutoDamagingError(Exception):
    """Raised when the fighter wants to attack itself."""
    pass

class FighterIsNotAliveError(Exception):
    """Raised when the fighter wants to attack itself."""
    pass

class Fighter(BaseModel):
    """
    Represents a fighter with attributes like health, damage, and defense.
    """
    name: str
    health: int = Field(ge=80,le=120)
    __max_health : int
    damage: int = Field(ge=15,le=30, frozen=True)
    defense: int = Field(ge=5,le=15, frozen=True)
    velocity: int = Field(ge=1,le=10, frozen=True)
    critical: float = Field(ge=0.05,le=0.25, frozen=True)
    blockage: float = Field(ge=0.05,le=0.25, frozen=True)
    
    def __init__(self, name: str, health: int, damage: int,
                 defense: int, velocity: int, critical: float,
                 blockage: float, **kwargs):
        super().__init__(name=name, health=health, damage=damage,
                          defense=defense, velocity=velocity,
                          critical=critical, blockage=blockage, **kwargs)
        self.__max_health = health

    def is_alive(self) -> bool:
        return self.health > 0

    def block(self) -> bool:
        return random.choices([True, False],
                              weights=[self.blockage, 1-self.blockage], k=1)[0]

    def is_critical(self) -> bool:
        return random.choices([True, False],
                              weights=[self.critical, 1-self.critical], k=1)[0]

    def heals(self):
        self.health = self.__max_health

    def receive_damage(self, damage_points, is_critical):
        final_damage = max(1, damage_points - self.defense)
        final_damage = final_damage * 2 if is_critical else final_damage
        self.health = self.health - final_damage if self.health > final_damage else 0
        

    def attack(self, rival: "Fighter") -> bool:
        if not self.is_alive():
            raise FighterIsNotAliveError("A dead fighter cannot attack.")
        if rival is self:
            raise FighterAutoDamagingError("The fighter cannot attack itself.")
        random.seed()

        if rival.block():
            return False
        
        rival.receive_damage(self.damage, self.is_critical())
        return True

