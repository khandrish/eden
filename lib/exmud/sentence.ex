# defmodule Exmud.Sentence do
#   @sentence "get the shiny red ring from the pouch in the backpack on the second shelf in the third alcove"

#   defmodule Command do
#     #defstruct object: %Exmud.,

#   end

#   def parse do
#     @sentence
#   #  |>
#   end
# end

# defmodule Exmud.Command do
#   defstruct subject: 42, # Just object id
#             verbs: [%Exmud.Verb{}],
#             direct_objects: []

# end

# defmodule Exmud.Predicate do
#   defstruct verb: nil

# end

# defmodule Exmud.Verb do
#   defstruct key: nil,
#             adverbs: ["carefully"]

# end

# defmodule Exmud.PrepositionalPhrase do
#   defstruct preposition: nil,
#             nouns: [%Exmud.Noun{}]

# end

# defmodule Exmud.Adjective do
#   defstruct adverbs: [],
#             key: nil

# end

# defmodule Exmud.Noun do
#   defstruct adjectives: [],
#             adverbs: []
#             article: "the",
#             key: nil,
#             prepositional_phrases: []

# end