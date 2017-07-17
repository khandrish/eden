defmodule Exmud.Engine.Graphql.Types do
  alias Exmud.DB
  alias Exmud.DB.Model.{AttributeModel, CallbackModel, CommandSetModel, ComponentModel, LockModel, ObjectModel,
                        RelationshipModel, ScriptModel, SystemModel, TagModel}
  import Ecto.Query
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Exmud.DB.Repo.EngineRepo


  object :object do
    @desc "The object's key. This is not guarenteed to be unique unless the application enforces it."
    field :key, :string

    @desc "The time that the object was created"
    field :date_created, :utc_datetime

    @desc "The callbacks associated with the object."
    field :callbacks, list_of(:callback), resolve: assoc(:callbacks)

    @desc "The command sets associated with the object."
    field :command_sets, list_of(:command_set), resolve: assoc(:command_sets)

    @desc "The components associated with the object."
    field :components, list_of(:component), resolve: assoc(:components)

    @desc "The callbacks associated with the object."
    field :locks, list_of(:lock), resolve: assoc(:locks)

    @desc "The relationships associated with the object."
    field :relationships, list_of(:relationship), resolve: assoc(:relationships)

    @desc "The scripts associated with the object."
    field :scripts, list_of(:script), resolve: assoc(:scripts)

    @desc "The tags associated with the object."
    field :tags, list_of(:tag), resolve: assoc(:tags)
  end


  object :attribute do
    @desc "The key that is being stored."
    field :attribute, :string

    @desc "The value that is being stored."
    field :data, :binary

    @desc "The component that the attribute belongs to."
    field :cid, :component, resolve: assoc(:component)
  end


  object :command_set do
    @desc "The key that is being stored."
    field :data, :binary

    @desc "The module that represents and seeds a component."
    field :callback_module, :binary

    @desc "The object that the command set belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end


  object :component do
    @desc "The key that is being stored."
    field :attribute, :string

    @desc "The module that represents and seeds a component."
    field :component, :binary

    @desc "The object that the component belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end


  object :callback do
    @desc "The callback string that is matched against when checking for callbacks."
    field :string, :string

    @desc "The callback module to be used if the callback string is matched."
    field :callback_function, :binary

    @desc "The object that the callback belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end


  object :lock do
    @desc "The callback module to be used when checking the lock."
    field :callback_module, :binary

    @desc "The data to be passed to the callback module when checking the lock."
    field :data, :binary

    @desc "The object that the lock belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end


  object :relationship do
    @desc "The tag which has been applied to an object."
    field :relationship, :string

    @desc "The category that the tag belongs to."
    field :category, :string

    @desc "The object that the relationship belongs to."
    field :object, :object, resolve: assoc(:object)

    @desc "The object that is the target of a relationship."
    field :target, :object, resolve: assoc(:object)
  end


  object :script do
    @desc "The name of the script. This is guaranteed to be unique per object."
    field :name, :string

    @desc "The callback module that contains the script logic."
    field :callback_module, :binary

    @desc "The state of the script."
    field :state, :binary

    @desc "The object that the script belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end


  object :tag do
    @desc "The tag which has been applied to an object."
    field :tag, :string

    @desc "The category that the tag belongs to."
    field :category, :string

    @desc "The object that the tag belongs to."
    field :object_id, :object, resolve: assoc(:object)
  end

  @desc """
  The `Utc DateTime` scalar type represents time values provided in the ISO
  datetime format (that is, the ISO 8601 format without the timezone offset, eg,
  "2015-06-24T04:50:34Z").
  """
  scalar :utc_datetime, description: "ISOz time" do
    parse &dt_from_iso8601(&1)
    serialize &dt_to_iso8601(&1)
  end

  def dt_from_iso8601(string), do: DateTime.from_iso8601(string)

  def dt_to_iso8601(dt), do: DateTime.to_iso8601(dt)

  @desc """
  The `Binary` scalar type represents non-primitive Elixir data structures.
  """
  scalar :binary, description: "Binary blob" do
    parse &:erlang.binary_to_term(&1)
    serialize &:erlang.term_to_binary(&1)
  end

  def parse(binary), do: :erlang.binary_to_term(binary)

  def serialize(term), do: :erlang.term_to_binary(term)
end
