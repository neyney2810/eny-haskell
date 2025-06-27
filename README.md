# eny-haskell

Implementation of Solving the mastermind game

The player function and the isConsistentWithBoard function implement a "smart player" algorithm for solving the Mastermind game efficiently by narrowing down possible guesses based on the feedback from previous guesses.
Approach: The player function will:
1. Generate All Possible Rows: It will define a sequence of all possible solutions. 
2. Find first Consistent Rows - run through all possible solutions (rows), with each row, the isConsistentWithBoard will check through each row, and it has to be consistent will all answered Rows before.
3. Return the First Consistent Row (as the next possible answer): The algorithm selects the first answer from the filtered list of consistent rows (remainingRows) as the next guess.