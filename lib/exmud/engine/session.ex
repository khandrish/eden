defmodule Exmud.Engine.Session do
  @moduledoc """
  A session represents a connection between a client and the engine.

  A Player can only have one active session at a time.

  Each session can only have one active client. If a new client connects, the previous one is forcibly disconnected and
  all output flows to the new client without interruption.

  an engine session is created when a client connects to a sim
  a session ends when the client disconnects
  a session is between a single client and a single sim. A client may be able to connect to multiple sims, with each
    connection representing a different session, even if the communication is over the same socket.
  If another client connects to a sim with an active session for the same user, any connected clients will be
    disconnected and the new client connection will serve and be served by the session
  The data for a user/sim session is pesisted and reused. This allows for things like keeping track of unacked messages
    so that they can be sent first on the next connection

  client a connects
  client a disconnects with messages
  client b connects and receives messages
  client a connects
  client b is disconnected
  client a gets all new messages
  """
  # use GenServer
end
