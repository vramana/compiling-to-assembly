# Multi-level Feedback Queue

Interactive programs that yield often are given higher priority compared to programs that yield infrequently.
Waiting for user input is critical than running a background process.

Rules:

- If a process has high priority, it is run first. Priority(A) > Priority(B) then A runs first,
- If Priority(A) == Priority(B), then A & B are run in round-robin fashion.
- When a process enters the scheduler, it is given the highest prority.
- If a process uses up all it's time slice at a given priority, it's given lower prority.
    - If a process uses up all it's time slice, it's given lower prority.
    - If a process yields before it's time slice is up, it stays at the same priority.
- After some time period, the scheduler will move all processes to the highest priority. (This avoids starvation)

