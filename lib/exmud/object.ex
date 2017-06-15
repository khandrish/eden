defmodule Exmud.Object do
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Exmud.Repo
  alias Exmud.Schema.Callback
  alias Exmud.Schema.Component
  alias Exmud.Schema.ComponentData
  alias Exmud.Schema.CommandSet
  alias Exmud.Schema.Object, as: Object
  alias Exmud.Schema.Tag
  import Ecto.Query
  import Exmud.Utils
  require Logger


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

  def get(objects, inclusion_filters \\ [:components, :callbacks, :command_sets, :tags]) do
    objects = List.wrap(objects)
    inclusion_filters = List.wrap(inclusion_filters)

    query =
      from object in Object,
        where: object.id in ^objects,
        preload: ^inclusion_filters

    results =
      Repo.all(query)
      |> normalize_get_results(inclusion_filters)

    {:ok, results}
  end

  def get(%Ecto.Multi{} = multi,
          multi_key,
          objects,
          inclusion_filters \\ [:components, :callbacks, :command_sets, :tags]) do
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
    args = %{string: callback_string, callback_module: :erlang.term_to_binary(callback_module), oid: oid}
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
      callback -> {:ok, :erlang.binary_to_term(callback.callback_module)}
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
    args = %{callback_module: :erlang.term_to_binary(callback_module), oid: oid}
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
    case Repo.one(command_set_query(oid, :erlang.term_to_binary(callback_module))) do
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
    Repo.delete_all(command_set_query(oid, :erlang.term_to_binary(callback_module)))
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
        where: tag.oid == ^oid,
        where: tag.key == ^key,
        where: tag.category == ^category
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
        or_where: command_set.callback_module == ^:erlang.term_to_binary(command_set)

    build_list_query(query, [{:command_sets, command_sets} | options])
  end

  defp build_list_query(query, [{:command_sets, [command_set | command_sets]} | options]) do
    query =
      from object in query,
        inner_join: command_set in assoc(object, :command_sets), on: object.id == command_set.oid,
        where: command_set.callback_module == ^:erlang.term_to_binary(command_set)

    build_list_query(query, [{:command_sets, command_sets} | options])
  end


  # List Components

  defp build_list_query(query, []), do: query
  defp build_list_query(query, [{_, []} | options]), do: build_list_query(query, options)

  defp build_list_query(query, [{:or_components, components} | options]) do
    components = wrap_or_query_params(components)
    build_list_query(query, [{:components, components} | options])
  end

  defp build_list_query(query, [{:components, [{:or, component} | components]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        or_where: component.component == ^:erlang.term_to_binary(component)

    build_list_query(query, [{:components, components} | options])
  end

  defp build_list_query(query, [{:components, [component | components]} | options]) do
    query =
      from object in query,
        inner_join: component in assoc(object, :components), on: object.id == component.oid,
        where: component.component == ^:erlang.term_to_binary(component)

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
        or_where: tag.key == ^key,
        where: tag.category == ^category

    build_list_query(query, [{:tags, tags} | options])
  end

  defp build_list_query(query, [{:tags, [{key, category} | tags]} | options]) do
    query =
      from object in query,
        inner_join: tag in assoc(object, :tags), on: object.id == tag.oid,
        where: tag.key == ^key,
        where: tag.category == ^category

    build_list_query(query, [{:tags, tags} | options])
  end

  defp new_changeset(key) do
    Object.changeset(%Object{}, %{key: key, date_created: DateTime.utc_now()})
  end

  defp wrap_or_query_params(params) do
    Enum.map(params, fn({:ok, _} = element) -> element
                       (params) -> {:or, params} end)
  end


  # Queries

  # Return the query used to find a specific callback mapped to a specific object.
  defp callback_query(oid, callback_string) do
    from callback in Callback,
      where: callback.oid == ^oid,
      where: callback.string == ^callback_string
  end

  # Return the query used to find a specific command set mapped to a specific object.
  defp command_set_query(oid, callback_module) do
    from command_set in CommandSet,
      where: command_set.callback_module == ^callback_module,
      where: command_set.oid == ^oid
  end

  # Return query used to find a specific attribute mapped to a specific object.
  defp component_data_query(oid, comp, attribute) do
    from component_data in ComponentData,
      inner_join: component in assoc(component_data, :component),
      where: component_data.attribute == ^attribute,
      where: component.component == ^:erlang.term_to_binary(comp),
      where: component.id == component_data.component_id,
      where: component.oid == ^oid
  end

  # Return query used to find a specific component mapped to a specific object.
  defp component_query(oid, component) do
    from component in Component,
      where: component.component == ^component,
      where: component.oid == ^oid,
      preload: :data
  end

  # Return the query used to find a specific tag mapped to a specific object.
  defp find_tag_query(oid, key, category) do
    from tag in Tag,
      where: tag.category == ^category,
      where: tag.key == ^key,
      where: tag.oid == ^oid
  end

  defp normalize_get_results(objects, [:components | rest]) do
    objects =
      Enum.map(objects, fn(object) ->
        %{object | components: Enum.map(object.components, fn(component) ->
            %{component | component: :erlang.binary_to_term(component.component),
                          data: Enum.map(component.data, fn(data) ->
              %{data | data: :erlang.binary_to_term(data.data)}
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
            %{callback | callback_module: :erlang.binary_to_term(callback.callback_module)}
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
            %{command_set | callback_module: :erlang.binary_to_term(command_set.callback_module)}
          end)
        %{object | command_sets: command_sets}
      end)

    normalize_get_results(objects, rest)
  end

  defp normalize_get_results(objects, _), do: objects
end
