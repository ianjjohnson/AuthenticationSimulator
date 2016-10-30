Name: _IAN_JOHNSON_           ID:   _46835377_

## Proposed Project

I would like to build a simulator for a link-layer authentication protocol
that I have been researching and designing. The idea would be to run simulations
to figure out with what frequency the authentication protocol correctly authenticates
good messages, and with what frequency it mis-authenticates intruding messages.
I call the protocol "time-based authentication." It works by having both parties
run parallel stream ciphers, which they use to encode an artificial delay
between the messages they send to one another. I intend to use the Erlang crypto
module for the necessary encryption, as the crypto module has support for CFB
encryption (cipher feedback mode). Since Elixir/Erlang have such strong
parallelization capabilities, I think that Elixir is a perfect way to perform this
modeling.

## Outline Structure

I intend to use a root supervisor which supervises a logger object and
another supervisor. The lower-level supervisor will supervise all of the
clients on the link-layer that are communicating with each other using the
time-based authentication protocol. I would also like to have a GenServer
running under the root supervisor which provides the encryption functionality
to the individual hosts, so that they don't need to handle encryption internally.
I intend to leverage the Erlang crypto library, and its built-in stream_init and
stream_encrypt functions.
