defmodule Exmud.GameObject do
  @opaque oid :: integer
  @type destination :: oid
  @type subject :: oid
  @type initial_location :: oid
  @type accessor :: oid
  @type access_type :: String
  @type traversing_object :: oid
  @type args :: term
  @type result :: boolean
  
  @doc """
  Called if the move is not quiet. This is called immediately before moving,
  while the subject is still in the old location.
  """
  @callback announce_move_from(subject, destination) :: subject
  
  @doc """
  Called if the move is not quiet. This is called immediately after moving,
  when the subject is in the new location.
  """
  @callback announce_move_to(subject, initial_location) :: subject
  
  @doc """
  Called with the result of an access call, along with any args used for the call.
  
  This method does not affect the lock check, but is a hook for things such as
  logging. The return value is ignored.
  """
  @callback at_access(subject, result, accessor, access_type) :: term
  
  @doc """
  Called after a move has been completed, whether or not it was quiet.
  """
  @callback at_after_move(subject, initial_location) :: subject
  
  @doc """
  Called after an object has successfully used this object to traverse
  to another object.
  """
  @callback at_after_traverse(subject, traversing_object, initial_location) :: term
  
  @doc """
  Called just before moving an object to its destination.
  """
  @callback at_before_move(subject, destination) :: boolean
  
  @doc """
  Called before command sets on an object are requested. This allows for
  dynamic changes to the command sets, or default handling of cases
  where there are no command sets added.
  """
  @callback at_cmdset_get(subject, args) :: term
  
  @doc """
  Called if an object fails to traverse this object.
  """
  @callback at_failed_traverse(subject, traversing_object) :: term
  
  @doc """
  Called the very first time an object is created and saved. This is generally
  not overloaded.
  """
  @callback at_first_save(subject, traversing_object) :: term
  
  @doc """
  Called if an object fails to traverse this object.
  """
  @callback at_get(subject, traversing_object) :: term
end