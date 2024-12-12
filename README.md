# Pong Game in Assembly Language

## Overview
This project is a Pong game implemented in 8086 assembly language. It features basic gameplay mechanics, sound effects, customizable patterns, and a simple user interface. The game supports two players and includes features such as moving paddles, a bouncing ball, and a score tracking system. 


## Features

### Gameplay
- **Two-Player Support:** Compete with another player to score points.
- **Game Modes:** Option to play with or without moving patterns.
- **Winning Condition:** First player to reach the maximum score wins.
- **Pause and Resume:** Press `P` to pause and resume gameplay.

### Patterns
- **Static and Moving Backgrounds:** Choose from multiple background patterns: 
  - `Space` for no patterns
  - `1` for Star pattern
  - `2` for Line pattern
  - `3` for Arrow pattern

### Sound Effects
- **Dynamic Sounds:** Experience sound effects for events like:
  - Paddle hits
  - Wall bounces
  - Scoring
  - Game over

### Visuals
- **Graphics:** ASCII-based visuals for the ball, paddles, and walls.
- **Customizable Colors:** Ball color and character are easily modifiable.


## Installation and Execution

1. **Setup Emulator**
   - Use an 8086 emulator such as [DOSBox](https://www.dosbox.com/) or [EMU8086](https://emu8086.com/).

2. **Compile the Code**
   - Use an assembler like TASM or MASM to compile the code:
     ```
     tasm game.asm
     tlink /t game.obj
     ```

3. **Run the Game**
   - Run the executable in your emulator:
     ```
     game.exe
     ```


## Controls

| Key       | Action                                 |
|-----------|---------------------------------------|
| `SPACE`   | Start the game or restart after game over |
| `P`       | Pause/Resume the game                 |
| `ESC`     | Exit the game                         |
| `1`       | Enable Star background                |
| `2`       | Enable Line background                |
| `3`       | Enable Arrow background               |
| `W/S`     | Move Player 1 paddle up/down          |
| `UP/DOWN` | Move Player 2 paddle up/down          |


## Code Structure

### Game Variables
- **Messages:** Strings for user interface prompts and notifications.
- **Scores:** Tracks the score for Player 1 and Player 2.
- **Ball Configuration:** Position, direction, and appearance of the ball.
- **Paddle Positions:** Coordinates for Player 1 and Player 2 paddles.

### Functions
- **Sound Effects:** Generates sounds for various game events.
- **Graphics Rendering:** Clears the screen, draws walls, and updates ball and paddle positions.
- **Gameplay Logic:** Updates game state, checks for collisions, and manages scoring.


## Customization
- Modify the ball character, colors, and speeds by editing:
  ```asm
  ball_char db 'O'
  ball_color db 0x0F
  game_speed dw 1
  ```
- Change the maximum score by updating:
  ```asm
  max_score db 5
  ```




## License
This project is licensed under the MIT License. Feel free to use and modify the code for educational purposes.


