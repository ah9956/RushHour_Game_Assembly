# 🚕 Rush Hour – Console-Based Game (x86 Assembly / MASM)

**Rush Hour** is a console-based 2D game developed in **x86 Assembly Language** using **MASM** and the **Irvine32 library**.  
The player controls a taxi navigating a grid-based city while avoiding NPC cars and obstacles, managing time, and maximizing score across multiple game modes.

---

## 🎮 Game Modes

### 🧑‍💼 Career Mode
- Progressive difficulty
- NPC traffic increases over time
- Score and time-based gameplay

### ⏱️ Time Attack
- Limited time to score maximum points
- Faster NPC movement

### ♾️ Endless Mode
- No time limit
- Game continues until collision or failure

---

## ✨ Features

- Console-based 2D grid gameplay
- Written entirely in **x86 Assembly**
- Player-controlled taxi movement
- Multiple NPC cars with random movement
- Collision detection with:
  - NPC cars
  - Obstacles
  - Boundaries
- Score tracking system
- Timer-based gameplay
- Persistent leaderboard using file handling
- Sound effects and background audio
- Menu-driven interface

---

## 🕹️ Controls

| Key | Action |
|----|-------|
| Arrow Keys | Move taxi |
| Enter | Select menu option |
| ESC | Exit game |

---

## 🛠️ Technologies Used

- **x86 Assembly Language**
- **MASM**
- **Irvine32 Library**
- **Console Graphics**
- **File Handling**
- **Sound Procedures**

---

## 📂 Project Structure

- `RushHour.asm` – Main game logic
- `Irvine32.inc` – Assembly support library
- `*.txt` – Leaderboard and data files
- `*.wav` – Sound effects

---

## 🏆 Leaderboard System

- Stores top player scores
- Loaded and saved using file I/O
- Displayed in-game via menu

---

## 🚀 How to Run

1. Install **MASM**
2. Set up **Irvine32 Library**
3. Open project in **Visual Studio**
4. Build and run the program

---

## 👤 Author

**Abdul Hannan**  
Bachelor’s in Artificial Intelligence  
FAST-NUCES  

---

## 📌 Notes

- Developed as an academic project to practice **low-level programming**
- Focuses on **logic building, memory management, and control flow**
- No high-level libraries or game engines used
