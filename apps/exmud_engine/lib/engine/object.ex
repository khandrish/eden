defmodule Exmud.Engine.Object do
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Exmud.DB.Repo
  alias Exmud.DB.Callback
  alias Exmud.DB.Component
  alias Exmud.DB.ComponentData
  alias Exmud.DB.CommandSet
  alias Exmud.DB.Object
  alias Exmud.DB.Tag
  import Ecto.Query
  import Exmud.Engine.Utils
  require Logger

  @get_inclusion_filters [:callbacks, :command_sets, :components, :locks, :relationships, :scripts, :tags]


  #
  # General object functions
  #


  def new(key) do
    case Repo.insert(new_changeset(key)) do
      {:ok, object} -> {:ok, object.id}
      {:error, changeset} -> {:error, normalize_ecto_errors(changeset.errors)}
    end
  end

  def new(%Ecto.Multi{} = multi, multi_key, key) do
    Multi.run(multi, multi_key, fn(_) ->
      new(key)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def delete(oid) do
    {:ok, _} = Repo.delete(%Object{id: oid})
    {:ok, oid}
  end

  def delete(%Ecto.Multi{} = multi, multi_key, oid) do
    Multi.run(multi, multi_key, fn(_) ->
      delete(oid)
    end)
  end

  def get(objects) do
    get(objects, @get_inclusion_filters)
  end

  def get(object, inclusion_filters) when is_list(object) == false do
    {:ok, results} = get(List.wrap(object), inclusion_filters)
    {:ok, List.first(results)}
  end

  def get(objects, inclusion_filters) do
    inclusion_filters = List.wrap(inclusion_filters)

    base_query =
      from object in Object,
        where: object.id in ^objects

    query = build_get_query(base_query, inclusion_filters)

    results =
      Repo.all(query)
      |> normalize_get_results(inclusion_filters)

    {:ok, results}
  end

  def get(%Ecto.Multi{} = multi,
          multi_key,
          objects) do
    get(multi, multi_key, objects, @get_inclusion_filters)
  end

  def get(%Ecto.Multi{} = multi,
          multi_key,
          objects,
          inclusion_filters) do
    Multi.run(multi, multi_key, fn(_) ->
      get(objects, inclusion_filters)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def list(options) do
    query =
      from object in Object,
        group_by: object.id,
        select: object.id

    options =
      Enum.map(options, fn({type, values}) -> {type, List.wrap(values)} end)

    build_list_query(query, options)
    |> Repo.all()
    |> (&({:ok, &1})).()
  end

  def list(%Ecto.Multi{} = multi, multi_key, options) do
    Multi.run(multi, multi_key, fn(_) ->
      list(options)
    end)
  end


  #
  # Component related functions
  #


  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def add_component(oid, component) do
    args = %{component: serialize(component),
             oid: oid}
    Repo.insert(Component.changeset(%Component{}, args))
    |> normalize_repo_result(oid)
  end

  def add_component(%Ecto.Multi{} = multi, multi_key, oid, component) do
    Multi.run(multi, multi_key, fn(_) ->
      add_component(oid, component)
    end)
  end

  # Being private, this would normally be down at the bottom but keeping it here so it doesn't get buried.
  defp get_component(oid, component) do
    case Repo.one(component_query(oid, serialize(component))) do
      nil -> {:error, :no_such_component}
      comp -> {:ok, comp}
    end
  end

  def has_component?(oid, component) do
    case Repo.one(component_query(oid, serialize(component))) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def has_component?(%Ecto.Multi{} = multi, multi_key, oid, component) do
    Multi.run(multi, multi_key, fn(_) ->
      has_component?(oid, component)
    end)
  end

  # Component/Attribute related functions

  def add_attribute(oid, component, attribute, data) do
    case get_component(oid, component) do
      {:ok, comp} ->
        args = %{data: serialize(data),
                 attribute: attribute}

        Ecto.build_assoc(comp, :data, args)
        |> Repo.insert()
        |> normalize_repo_result(oid)
      error ->
        error
    end
  end

  def add_attribute(%Ecto.Multi{} = multi, multi_key, oid, component, attribute, data) do
    Multi.run(multi, multi_key, fn(_) ->
      add_attribute(oid, component, attribute, data)
    end)
  end

  def attribute_equals?(oid, component, attribute, data) do
    case get_component(oid, component) do
      {:ok, comp} ->
        query =
          component_data_query(oid, component, attribute)

        query =
          from component_data in query,
            where: component_data.data == ^serialize(data)

        case Repo.one(query) do
          nil ->
            {:ok, false}
          _result ->
            {:ok, true}
        end
      error ->
        error
    end
  end

  def attribute_equals?(%Ecto.Multi{} = multi, multi_key, oid, component, attribute, data) do
    Multi.run(multi, multi_key, fn(_) ->
      attribute_equals?(oid, component, attribute, data)
    end)
  end

  def get_attribute(oid, component, attribute) do
    case Repo.one(component_data_query(oid, component, attribute)) do
      nil -> {:error, :no_such_attribute}
      component_data -> {:ok, deserialize(component_data.data)}
    end
  end

  def get_attribute(%Ecto.Multi{} = multi, multi_key, oid, component, attribute) do
    Multi.run(multi, multi_key, fn(_) ->
      get_attribute(oid, component, attribute)
    end)
  end

  def has_attribute?(oid, component, attribute) do
    case Repo.one(component_data_query(oid, component, attribute)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def has_attribute?(%Ecto.Multi{} = multi, multi_key, oid, component, attribute) do
    Multi.run(multi, multi_key, fn(_) ->
      has_attribute?(oid, component, attribute)
    end)
  end

  def remove_attribute(oid, component, attribute) do
    component_data_query(oid, component, attribute)
    |> Repo.delete_all()
    |> case do
      {1, _} -> {:ok, oid}
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end

  def remove_attribute(%Ecto.Multi{} = multi, multi_key, oid, component, attribute) do
    Multi.run(multi, multi_key, fn(_) ->
      remove_attribute(oid, component, attribute)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def update_attribute(oid, component, attribute, data) do
    case Repo.one(component_data_query(oid, component, attribute)) do
      nil -> {:error, :no_such_attribute}
      object ->
        Repo.update(ComponentData.changeset(object, %{data: serialize(data)}))
        |> normalize_repo_result(oid)
    end
  end

  def update_attribute(%Ecto.Multi{} = multi, multi_key, oid, component, attribute, data) do
    Multi.run(multi, multi_key, fn(_) ->
      update_attribute(oid, component, attribute, data)
    end)
  end


  #
  # Callback related functions
  #


  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def add_callback(oid, callback_string, callback_module) do
    args = %{string: callback_string, callback_module: serialize(callback_module), oid: oid}
    Repo.insert(Callback.changeset(%Callback{}, args))
    |> normalize_repo_result(oid)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add callback onto non existing object `#{oid}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result -> result
    end
  end

  def add_callback(%Ecto.Multi{} = multi, multi_key, oid, callback_string, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      add_callback(oid, callback_string, callback_module)
    end)
  end

  def get_callback(oid, callback_string) do
    case get_callback(oid, callback_string, nil) do
      {:ok, nil} -> {:error, :no_such_callback}
      result -> result
    end
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def get_callback(oid, callback_string, default_callback_module) do
    case Repo.one(callback_query(oid, callback_string)) do
      nil -> {:ok, default_callback_module}
      callback -> {:ok, deserialize(callback.callback_module)}
    end
  end

  def get_callback(%Ecto.Multi{} = multi, multi_key, oid, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      get_callback(oid, callback_string)
    end)
  end

  def get_callback(%Ecto.Multi{} = multi, multi_key, oid, callback_string, default_callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      get_callback(oid, callback_string, default_callback_module)
    end)
  end

  def has_callback?(oid, callback_string) do
    case Repo.one(callback_query(oid, callback_string)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def has_callback?(%Ecto.Multi{} = multi, multi_key, oid, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      has_callback?(oid, callback_string)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def delete_callback(oid, callback_string) do
    Repo.delete_all(callback_query(oid, callback_string))
    |> case do
      {1, _} -> {:ok, oid}
      {0, _} -> {:error, :no_such_callback}
      _ -> {:error, :unknown} # What are the error conditions? What needs to be handled?
    end
  end

  def delete_callback(%Ecto.Multi{} = multi, multi_key, oid, callback_string) do
    Multi.run(multi, multi_key, fn(_) ->
      delete_callback(oid, callback_string)
    end)
  end


  #
  # Command set related functions
  #


  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def add_command_set(oid, callback_module) do
    args = %{callback_module: serialize(callback_module), oid: oid}
    Repo.insert(CommandSet.changeset(%CommandSet{}, args))
    |> normalize_repo_result(oid)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add command set onto non existing object `#{oid}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end

  def add_command_set(%Ecto.Multi{} = multi, multi_key, oid, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      add_command_set(oid, callback_module)
    end)
  end

  def has_command_set?(oid, callback_module) do
    case Repo.one(command_set_query(oid, serialize(callback_module))) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def has_command_set?(%Ecto.Multi{} = multi, multi_key, oid, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      has_command_set?(oid, callback_module)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def delete_command_set(oid, callback_module) do
    Repo.delete_all(command_set_query(oid, serialize(callback_module)))
    |> case do
      {1, _} -> {:ok, oid}
      {0, _} -> {:error, :no_such_command_set}
      _ -> {:error, :unknown}
    end
  end

  def delete_command_set(%Ecto.Multi{} = multi, multi_key, oid, callback_module) do
    Multi.run(multi, multi_key, fn(_) ->
      delete_command_set(oid, callback_module)
    end)
  end


  #
  # Tag related functions
  #


  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def add_tag(oid, key, category \\ "__DEFAULT__") do
    args = %{category: category,
             oid: oid,
             key: key}
    Repo.insert(Tag.changeset(%Tag{}, args))
    |> normalize_repo_result(oid)
    |> case do
      {:error, errors} ->
        if Keyword.has_key?(errors, :oid) do
          Logger.warn("Attempt to add tag onto non existing object `#{oid}`")
          {:error, :no_such_object}
        else
          {:error, errors}
        end
      result ->
        result
    end
  end

  def add_tag(%Ecto.Multi{} = multi, multi_key, oid, key, category \\ "__DEFAULT__") do
    Multi.run(multi, multi_key, fn(_) ->
      add_tag(oid, key, category)
    end)
  end

  def has_tag?(oid, key, category \\ "__DEFAULT__") do
    case Repo.one(find_tag_query(oid, key, category)) do
      nil -> {:ok, false}
      _object -> {:ok, true}
    end
  end

  def has_tag?(%Ecto.Multi{} = multi, multi_key, oid, key, category \\ "__DEFAULT__") do
    Multi.run(multi, multi_key, fn(_) ->
      has_tag?(oid, key, category)
    end)
  end

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def remove_tag(oid, key, category \\ "__DEFAULT__") do
    Repo.delete_all(
      from tag in Tag,
        where: tag.oid == ^oid
          and tag.key == ^key
          and tag.category == ^category
    )
    |> case do
      {num, _} when num > 0 -> {:ok, oid}
      {0, _} -> {:error, :no_such_tag}
      _ -> {:error, :unknown}
    end
  end

  def remove_tag(%Ecto.Multi{} = multi, multi_key, oid, key, category \\ "__DEFAULT__") do
    Multi.run(multi, multi_key, fn(_) ->
      remove_tag(oid, key, category)
    end)
  end


  #
  # Private functions
  #


  # Get Query

  defp build_get_query(query, []), do: query

  defp build_get_query(query, [:callbacks | inclusion_filters]) do
    query =
      from object in query,
        left_join: callback in assoc(object, :callbacks),
        preload: [:callbacks]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:command_sets | inclusion_filters]) do
    query =
      from object in query,
        left_join: command_set in assoc(object, :command_sets),
        preload: [:command_sets]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:components | inclusion_filters]) do
    query =
      from object in query,
        left_join: component in assoc(object, :components),
        left_join: data in assoc(component, :data),
        preload: [components: {component, data: data}]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:locks | inclusion_filters]) do
    query =
      from object in query,
        left_join: lock in assoc(object, :locks),
        preload: [:locks]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:relationships | inclusion_filters]) do
    query =
      from object in query,
        left_join: relationship in assoc(object, :relationships),
        preload: [:relationships]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:scripts | inclusion_filters]) do
    query =
      from object in query,
        left_join: script in assoc(object, :scripts),
        preload: [:scripts]

    build_get_query(query, inclusion_filters)
  end

  defp build_get_query(query, [:tags | inclusion_filters]) do
    query =
      from object in query,
        left_join: tag in assoc(object, :tags),
        preload: [:tags]

    build_get_query(query, inclusion_filters)
  end


  # List Attributes

  defp build_list_query(query, []), do: query
  defp build_list_query(query, [{_, []} | options]), do: build_list_query(query, options)

  defp build_list_query(query, [{:or_attributes, attributes} | options]) do
    attributes = wrap_or_query_params(attributes)
    build_list_query(query, [{:attributes, attributes} | options])
  end

  defp build_list_query(query, [{:attributes, [{:or, {component, attribute, data}} | attributes]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        inner_join: data in assoc(component, :data), on: data.component_id == component.id,
        or_where: data.attribute == ^attribute
          and component.component == ^serialize(component)
          and data.data == ^serialize(data)

    build_list_query(query, [{:attributes, attributes} | options])
  end

  defp build_list_query(query, [{:attributes, [{component, attribute, data} | attributes]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        inner_join: data in assoc(component, :data), on: data.component_id == component.id,
        where: data.attribute == ^attribute
          and component.component == ^serialize(component)
          and data.data == ^serialize(data)

    build_list_query(query, [{:attributes, attributes} | options])
  end

  defp build_list_query(query, [{:attributes, [{:or, {component, attribute}} | attributes]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        inner_join: data in assoc(component, :data), on: data.component_id == component.id,
        or_where: data.attribute == ^attribute
          and component.component == ^serialize(component)

    build_list_query(query, [{:attributes, attributes} | options])
  end

  defp build_list_query(query, [{:attributes, [{component, attribute} | attributes]} | options])  do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        inner_join: data in assoc(component, :data), on: data.component_id == component.id,
        where: data.attribute == ^attribute
          and component.component == ^serialize(component)

    build_list_query(query, [{:attributes, attributes} | options])
  end


  # List Callbacks

  defp build_list_query(query, [{:or_callbacks, callback_strings} | options]) do
    callback_strings = wrap_or_query_params(callback_strings)
    build_list_query(query, [{:callbacks, callback_strings} | options])
  end

  defp build_list_query(query, [{:callbacks, [{:or, callback_string} | callback_strings]} | options]) do
    query =
      from object in query,
        inner_join: callback in assoc(object, :callbacks), on: object.id == callback.oid,
        or_where: callback.string == ^callback_string

    build_list_query(query, [{:callbacks, callback_strings} | options])
  end

  defp build_list_query(query, [{:callbacks, [callback_string | callback_strings]} | options]) do
    query =
      from object in query,
        inner_join: callback in assoc(object, :callbacks), on: object.id == callback.oid,
        where: callback.string == ^callback_string

    build_list_query(query, [{:callbacks, callback_strings} | options])
  end


  # List Command Sets

  defp build_list_query(query, [{:or_command_sets, command_sets} | options]) do
    command_sets = wrap_or_query_params(command_sets)
    build_list_query(query, [{:command_sets, command_sets} | options])
  end

  defp build_list_query(query, [{:command_sets, [{:or, command_set} | command_sets]} | options]) do
    query =
      from object in query,
        inner_join: command_set in assoc(object, :command_sets), on: object.id == command_set.oid,
        or_where: command_set.callback_module == ^serialize(command_set)

    build_list_query(query, [{:command_sets, command_sets} | options])
  end

  defp build_list_query(query, [{:command_sets, [command_set | command_sets]} | options]) do
    query =
      from object in query,
        inner_join: command_set in assoc(object, :command_sets), on: object.id == command_set.oid,
        where: command_set.callback_module == ^serialize(command_set)

    build_list_query(query, [{:command_sets, command_sets} | options])
  end


  # List Components

  defp build_list_query(query, [{:or_components, components} | options]) do
    components = wrap_or_query_params(components)
    build_list_query(query, [{:components, components} | options])
  end

  defp build_list_query(query, [{:components, [{:or, component} | components]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        or_where: component.component == ^serialize(component)

    build_list_query(query, [{:components, components} | options])
  end

  defp build_list_query(query, [{:components, [component | components]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        where: component.component == ^serialize(component)

    build_list_query(query, [{:components, components} | options])
  end


  # List Keys

  defp build_list_query(query, [{:or_objects, objects} | options]) do
    objects = wrap_or_query_params(objects)
    build_list_query(query, [{:objects, objects} | options])
  end

  defp build_list_query(query, [{:objects, [{:or, key} | keys]} | options]) do
    query =
      from object in query,
        or_where: object.key == ^key

    build_list_query(query, [{:objects, keys} | options])
  end

  defp build_list_query(query, [{:objects, [key | keys]} | options]) do
    query =
      from object in query,
        where: object.key == ^key

    build_list_query(query, [{:objects, keys} | options])
  end


  # List Tags

  defp build_list_query(query, [{:or_tags, tags} | options]) do
    tags = wrap_or_query_params(tags)
    build_list_query(query, [{:tags, tags} | options])
  end

  defp build_list_query(query, [{:tags, [{:or, {key, category}} | tags]} | options]) do
    query =
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
        or_where: tag.key == ^key
          and tag.category == ^category

    build_list_query(query, [{:tags, tags} | options])
  end

  defp build_list_query(query, [{:tags, [{key, category} | tags]} | options]) do
    query =
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
        where: tag.key == ^key
          and tag.category == ^category

    build_list_query(query, [{:tags, tags} | options])
  end

  defp new_changeset(key) do
    Object.changeset(%Object{}, %{key: key, date_created: DateTime.utc_now()})
  end

  defp wrap_or_query_params(params) do
    Enum.map(params, fn({:ok, _} = element) -> element
                       (param) -> {:or, param} end)
  end


  # Queries

  # Return the query used to find a specific callback mapped to a specific object.
  defp callback_query(oid, callback_string) do
    from callback in Callback,
      where: callback.oid == ^oid
        and callback.string == ^callback_string
  end

  # Return the query used to find a specific command set mapped to a specific object.
  defp command_set_query(oid, callback_module) do
    from command_set in CommandSet,
      where: command_set.callback_module == ^callback_module
        and command_set.oid == ^oid
  end

  # Return query used to find a specific attribute mapped to a specific object.
  defp component_data_query(oid, comp, attribute) do
    from component_data in ComponentData,
      inner_join: component in assoc(component_data, :component),
      where: component_data.attribute == ^attribute
        and component.component == ^serialize(comp)
        and component.id == component_data.component_id
        and component.oid == ^oid
  end

  # Return query used to find a specific component mapped to a specific object.
  defp component_query(oid, component) do
    from component in Component,
      where: component.component == ^component
        and component.oid == ^oid,
      preload: :data
  end

  # Return the query used to find a specific tag mapped to a specific object.
  defp find_tag_query(oid, key, category) do
    from tag in Tag,
      where: tag.category == ^category
        and tag.key == ^key
        and tag.oid == ^oid
  end

  defp normalize_get_results(objects, [:components | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        %{object | components: Enum.map(object.components, fn(component) ->
            %{component | component: deserialize(component.component),
                          data: Enum.map(component.data, fn(data) ->
              %{data | data: deserialize(data.data)}
            end)}
        end)}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, [:callbacks | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        callbacks =
          Enum.map(object.callbacks, fn(callback) ->
            %{callback | callback_module: deserialize(callback.callback_module)}
          end)

        %{object | callbacks: callbacks}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, [:command_sets | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        command_sets =
          Enum.map(object.command_sets, fn(command_set) ->
            %{command_set | callback_module: deserialize(command_set.callback_module)}
          end)
        %{object | command_sets: command_sets}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, _), do: objects
end