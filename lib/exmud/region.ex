defmodule Exmud.Region do
  @moduledoc """
  An abstract container for areas and other regions.

  Regions
  """


# regions
#   can hold regions or areas
#   used for hierarchical structuring of world
#   top region is world
# areas
#   an abstract place within the world
#   every object belongs to an area
#   every area belongs to a region
#   an area is both a point in the world and can itself have its own coordiate system
#     using postgres + posdtgis + pgrouting pathfinding will be built in
# portals
#   connections from one area to another
#   can be of multiple types for different handling such as for sound, water, air, tiny exits, and so on
#   default type acts like your standard exit with built in options for doors and so on
# scenes
#   scenes have to be generated from static/dynamic area descriptions and local characters/items
# locks
#   permission system

end