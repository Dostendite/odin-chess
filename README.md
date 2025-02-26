## Ruby Chess for TOP

> [!NOTE]
> I recommend you increase your **terminal font size** to play
> the game comfortably, as it uses small unicode symbols.

**Possible improvements:**
- Add tests for en passant
*(Check that the pawn has the available move,
and that the captured piece exists **and** gets captured)*
- Remove the Move Validator Module and move its methods to the Board Class
- Replace `if x.nil?` with `if x"`
- Run Rubocop

**Welcome to my CLI game of Chess! The capstone project for the Ruby course.**

The game is equipped with tests for game rules,
possible moves, predicate methods, and more.

Please let me know if you find any bugs or things to improve!

![CLI chess game screenshot](https://i.imgur.com/ZrWICEL.png)

## Cool feature ideas

### Stockfish
Plug stockfish or some other AI into the game and let the player choose a difficulty mode before playing

### Game timers
Add a timer for each player (Each player can choose their own time limit)

### Board / piece themes
Let the player choose from a variety of board & piece colors / styles

### Replay / Analysis tool
Implement a tool where the player can visit previously played games, navigate to the previous / next moves and add a note for each move.
