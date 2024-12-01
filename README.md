# compiling-to-assembly

## Building and Using the Compiler

Follow these steps to build and use the compiler:

1. To build the compiler, use the following command:

```bash
zig build
```

2. To run the compiler with built-in input, execute:

```bash
zig build run
```

This generates an assembly file named `main.s` in the current directory.
The generated assembly targets the **Linux ARM64 architecture**.

3. Prepare the Environment

- **Linux Users**: No additional setup is needed; proceed to the next step.
- **MacOS Users**: Install Docker and run the following commands to set up the environment:

```bash
docker compose up -d
docker compose exec app bash
```

This opens a bash shell within the container.


4. Compile the assembly file into an executable named `a.out` using `gcc`:

```bash
gcc main.s -o a.out
```


5. Execute the compiled program with:

```bash
./a.out
```


**Notes**:

- Ensure the required tools (`zig`, `gcc`, and `docker` for MacOS) are installed.
- For cross-platform compatibility, verify Docker is correctly configured on non-Linux systems.


