# Simulator

## What this project is

This project is a network simulator for a link-layer authentication protocol I'm working on for a research project. The simulator has a set of nodes who are communicating, as well as a single attacker which is attempting to send false messages to one host on the network. The authentication protocol uses time-based authentication, so it assumes that the sender and receiver share parallel stream ciphers which they use to encode an artificial delay. This simulator keeps track of a number of different potential window sizes during which a recipient will accept a new message, and can write data about the false/true positive/negative rate of authentication.

The simulator is currently running, collecting preliminary data to be used for a grant proposal to pursue more research into this authentication strategy.

## To run the simulator:
```elixir
iex -S mix

Simulator.run
```

This will automatically generate log and time files as the simulator runs. To write auth.dat files, use:

```elixir
Simulator.Logger.write_authenticators
```
