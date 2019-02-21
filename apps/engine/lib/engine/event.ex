defmodule Exmud.Engine.Event do
  @moduledoc """
  Events are data structures which describe something that has taken place within the Engine.

  The most common Events will be those triggered from Commands which have run. For example, a 'say' command might
  generate 42 different message events, each one being sent to a different character in the room.

  All Events will be run asynchronously after the Command/Script/Service has finished executing, and do so after the
  transaction for the same has been committed. This way there won't be extra messages sent out due to a forced retry
  from a DB/transaction conflict.

  If multiple events contain the same data, multiple message events containing the same string for example, it is better
  to use a single event with a list of Object id's instead. This will be more memory efficient. Please not that this
  assumes the default message event handler is in place, or that the replacement contains the same logic.
  """

  require Logger

  defstruct [
    :type,
    :data,
    :object_id
  ]

  #
  # API
  #

  def listen( event_types ) do
    event_types = List.wrap( event_types )

    for event_type <- event_types do
      Registry.register( Exmud.Engine.GlobalEventRegistry, event_type, nil )
    end
  end

  def listen( object_id, event_types ) do
    event_types = List.wrap( event_types )

    for event_type <- event_types do
      Registry.register( Exmud.Engine.TargetedEventRegistry, object_id, event_type )
    end
  end

  def dispatch( %__MODULE__{ object_id: nil } = event ) do
    dispatch_global_event( event )
  end

  def dispatch( %__MODULE__{} = event ) do
    object_ids = List.wrap( event.object_id )

    for object_id <- object_ids do
      Registry.dispatch( Exmud.Engine.TargetedEventRegistry, object_id, fn entries ->
        for { pid, match } <- entries do
          if Regex.regex?( match ) and Regex.match?( match, event.type ) do
            send( pid, { :event, %{ event | object_id: object_id } } )
          else
            if match == event.type do
              send( pid, { :event, %{ event | object_id: object_id } } )
            end
          end
        end
      end)
    end

    dispatch_global_event( event )
  end

  defp dispatch_global_event( event ) do
    object_ids = List.wrap( event.object_id )

    for object_id <- object_ids do
      Registry.dispatch( Exmud.Engine.TargetedEventRegistry, object_id, fn entries ->
        for { pid, match } <- entries do
          if Regex.regex?( match ) and Regex.match?( match, event.type ) do
            send( pid, { :event, %{ event | object_id: object_id } } )
          else
            if match == event.type do
              send( pid, { :event, %{ event | object_id: object_id } } )
            end
          end
        end
      end)
    end
  end
end
