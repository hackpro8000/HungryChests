# GAME DESIGN DOCUMENT: MIMIC ROULETTE
**Date:** January 24, 2026  
**Status:** Core Concept / Draft

---

## 1. CORE GAMEPLAY LOOP
The game is a 1v1 turn-based strategy "Russian Roulette" style game played on a 5x5 chest grid.

### 1.1 Matchmaking & Seating
* **The Platform:** A 5x5 chest grid with two "Wooden Plank Chairs" on either side.
* **Player Count:** A 3D UI above the platform displays "0/2 Players."
* **Initialization:** Once two players sit, the counter disappears and the match begins.
* **Camera:** Shifts to a fixed, angled bird’s-eye view of the board.

### 1.2 The Mimic Phase (Preparation)
* **Customization:** The 5x5 grid renders chests in a checkerboard pattern using both players' equipped cosmetics.
* **Selection:** Both players have **10 seconds** to secretly click a chest to turn it into their "Mimic."
* **Conflict Resolution:** If both choose the same chest, the system automatically randomizes both choices.

### 1.3 The Game Phase (Turns)
* **Objective:** Take turns opening chests while avoiding the opponent's Mimic.
* **Turn Timer:** 10 seconds per choice.
* **Outcome Scenarios:**
    * **Empty Chest:** Player is safe. Receives a tiny instant Cash reward.
    * **Rare Big Cash Reward:** Random chance for a large payout.
    * **The Mimic:** The player is eaten. (Animation: Player walks to chest and is pulled in, or instant teleport into the mimic's mouth).
* **End Game:** Winner gets large Cash/Trophies. Loser gets a small pity reward. Both respawn at the lobby.

---

## 2. MONETIZATION & SHOP
### 2.1 Gamepasses (Robux)
* **Multipliers:** x2 Win Streak, x2 Trophies, x2 Cash.
* **VIP Bundle:** Includes all x2 multipliers, VIP Chat Tag, Overhead Tag, and exclusive VIP Chair/Chest skins.
* **Utilities:** Extra Walkspeed, Win-streak Restoration.

### 2.2 In-Game "Sabotage" / Pay-to-Win Features
* **Reveal Mimic:** Pay to see where the enemy mimic is.
* **Double Mimic:** Pay to place a second mimic on the board.
* **Hints:** Pay to see a range of numbers (e.g., "Between chest 5 and 10") where the mimic is.
* **Troll/Scare:** Pay to trigger a jumpscare or buy the "Troll Bundle."

### 2.3 Crates & Gacha
| Crate Type | Cost | Rare Odds | Legendary Odds | Divine Odds |
| :--- | :--- | :--- | :--- | :--- |
| **Common** | 500 Cash | 90% | 9.2% | 0.8% |
| **Premium** | 25 Robux | 9.2% | 80.8% | 10% |
* **Visuals:** A horizontal bar-spin animation. Highlights are Green (Rare), Red (Legendary), and Gold (Divine).
* **Features:** Bulk buy (x5)