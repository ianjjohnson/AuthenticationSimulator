# Simulator

## To run the simulator:
```elixir
iex -S mix

Simulator.run
```

This will automatically generate log and time files as the simulator runs. To write auth.dat files, use:

```elixir
Simulator.Logger.write_authenticators
```
