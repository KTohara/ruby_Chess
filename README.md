# Ruby Chess
Final Ruby curriculum project from [The Odin Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project)

### Play ###
Head to [repl.it](https://replit.com/@KenTohara/rubyChess)!

Press the green run button at the top of the page.

[![Run on Repl.it](https://repl.it/badge/github/KTohara/ruby_Chess)](https://replit.com/@KenTohara/rubyChess)

### Features
- *Move:* Basic movement types for Pawn, Rook, Knight, Bishop, Queen, and King
- *Capture:* Removes an enemy piece from the board
- *Check:* Notifies a player when their King can be captured in the next turn.
- *Highlight Legal Moves:* Red circles indicate moves, green circle indicate captures
- *Keyboard input*: WASD controls for being able to move freely around the board. No more typing in inputs!
- *Algebraic Notation*: Records every move made in the game into [algebraic notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess))
- *Save/Load:* Save any time, load a game when starting up the program.
- *Checkmate:* Wins the game for a player when the opposing player is in check, and the opposing player cannot escape out of check.
- *Stalemate:* Draws the game when the player is not in check, but it's king cannot make any legal moves.
- *[Insufficient Material](https://en.wikipedia.org/wiki/Rules_of_chess#Dead_position)*: Draws the game in any of the following conditions
  - king vs king
  - king vs king and bishop
  - king vs king and knight
  - king and bishop vs king and bishop, where bishops share the same colored square
- *Pawn promotions:* Pawn is able to promote itself into a Rook, Knight, Bishop, or Queen
- *En Passant:* Pawn is able to capture an enemy pawn, when the enemy pawn has double jumped into an adjacent row of a pawn.
- *Castling:* Rook and King move during one turn. Handles King and Queenside Castling.

### Thoughts
This was the final project for the Ruby curriculum for the Odin Project. I learned a TON from this.
Most of it was coded in tandem with TDD, but there were definitely points where I needed to code first, then test, then go back into refactoring.

*Do your best to keep your classes modular and clean and your methods doing only one thing each.*
*This is the largest program that you’ve written, so you’ll definitely start to see the benefits of good organization (and testing) when you start running into bugs.*

I started to code this project with a decent outline of what I wanted. Unfortunately, there were some points during the project where I felt there should have been better planning on my part.
I think overall, having a UML diagram or overall structure of where everything needed to go would have been super helpful for me.

Overall, this was a fun and challenging project! I would love to look back at this some day and really look at how much I could improve (Which I already understand; there is a lot).