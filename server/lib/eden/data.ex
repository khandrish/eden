defmodule Eden.Data do

  # 
  # This module serves as the unified interface for accessing and manipulating data objects
  # both ephemeral and persisted. It abstracts away the difference between the cache and the
  # repository to make code that needs to work with data simpler to write, understand, and maintain.
  #
  # Example logic:
  # 
  # when getting a data object, first check to see if it is in the cache and if not load from database
  # 
  # when updating object, save changes locally and increment changes counter and if enough changes start task to sync cache
  #   can force sync on single object
  #   can flush all changes
  # 
  # when creating object, save changes locally and increment changes counter and if enough changes start task to sync cache
  #   can force sync on single object
  #   can flush all changes
  # 
  # 

end