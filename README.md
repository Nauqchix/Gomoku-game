# 🟦 Gomoku Game (Caro 15×15)

This project implements a console-based **Gomoku (Five-in-a-Row)** game.  
Two players (X and O) place stones on a 15×15 grid and attempt to be the first to get **five consecutive stones** in any direction.

This project is written for the course **CO2008 – Computer Architecture**, Group 16.

---

## 🎮 Features

- ✔️ 15×15 game board printed in console  
- ✔️ Two-player gameplay (Player X and Player O)  
- ✔️ Input coordinates with full validation  
- ✔️ Prevents overwriting existing moves  
- ✔️ Win detection in 4 directions:
  - Horizontal  
  - Vertical  
  - Main diagonal  
  - Anti-diagonal  
- ✔️ Detects draw when the board is full  
- ✔️ Clean, modular code (ASM)

---

## ▶️ How to Run the Program

### **Using MARS / SPIM GUI**
1. Open `Gomoku.asm`
2. Click **Assemble**
3. Click **Run → Go**

### **Input Format**
You must enter coordinates in the form:

Example:


- `x` = row index (0–14)  
- `y` = column index (0–14)  

Player X always moves first.

---

## 📂 Repository Structure


---

## 🧩 Game Rules

A player wins if they achieve **five consecutive marks** in any direction:

### Horizontal
X X X X X

### Vertical
X
X
X
X
X

### Main Diagonal
X . . . .
. X . . .
. . X . .
. . . X .
. . . . X

### Anti Diagonal
. . . . X
. . . X .
. . X . .
. X . . .
X . . . .

If the board fills without any player forming a streak of five → **Draw**.

---

## 🛠️ Technologies Used

- **MIPS Assembly**
- **MARS / SPIM simulator**
- System calls for console I/O

---
## 👥 Authors 
| **Nguyễn Hoàng Quân** |
---

