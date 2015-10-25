defmodule Eden.Sandbox do
  use GenServer
  use Phoenix.Channel

  # API
  def start_link do
  	GenServer.start_link(__MODULE__, nil, name: :sandbox)
  end

  def puppet_character(name, player_id, player_roles) do
  	# search for character
  	# if character exists
  	#	if player has permission
  	#		mark character as active
  	#		mark character as being puppeted by player
  	#		return welcome message/screen and news/whatever else
  end

  # Callbacks
  def init(_input) do
  	{:ok, %{}}
  end

  def handle_call({:input, input}, _from, state) do
  	# Process input
  	#actions = loop([input])

  	#for action <- actions, do:
  	#	case action of
  	#		{:broadcast, message} ->
  	#			Eden.Endpoint.broadcast! socket, "new_msg", %{body: body}
  	#	end
  	#end
  	
  	# Take message/recipient pairs and send

  	# Send messages to self using send_after - this is how all timed events are triggered
  	# This includes long term movement like ferries/boats, ai "ticks", and so on
    {:noreply, state}
  end

  defp loop(inputs) do
  	#for input <- inputs, do:
  	#	{:broadcast, input}
  	#end
  	# for input in input_list
  	# 	tokenize input
  	# 	parse input
  	# 	process command
  	# 	apply transformations
  	# 	send messages
  end
end