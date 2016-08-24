defmodule Eden.Entity do
  defstruct id: nil, components: %{}
  
  alias Amnesia.Selection
  alias Apex.Format, as: Ap
  alias Eden.Database.EntityData, as: ED
  require Logger
  use Amnesia

  @component_flag :component

  def new do
    ED.write(%ED{component: "entity", key: "created", value: Timex.now}).id
  end

  def add_component(entity, component) do
    %ED{id: entity, component: component, key: @component_flag, value: true}
    |> ED.write
  end

  def remove_component(entity, component) do
    ED.match(id: entity, component: component)
    |> delete
  end

  def has_component?(entity, component) do
    [{{ED, :'$1', :'$2', :_ , :_},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'}}],
      [:'$1'] }]
    |> has?()
  end

  def get_key(entity, component, key) do
    [{{ED, :'$1', :'$2', :'$3' , :'$4'},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'},
      {:'==', key, :'$3'}}],
      [:'$4'] }]
    |> ED.select()
    |> Selection.values()
    |> List.first()
  end

  def get_all_keys(component, key) do
    [{{ED, :_, :'$2', :'$3' , :'$4'},
      [{:'and', {:'==', component, :'$2'},
      {:'==', key, :'$3'}}],
      [:'$4'] }]
    |> ED.select()
    |> Selection.values()
  end

  def add_key(entity, component, key, value \\ nil) do
    %ED{id: entity, component: component, key: key, value: value}
    |> ED.write
  end

  def remove_key(entity, component, key) do
    ED.match(id: entity, component: component, key: key)
    |> delete
  end

  def has_key?(entity, component, key) do
    [{{ED, :'$1', :'$2', :'$3' , :_},
      [{:'and', {:'==', component, :'$2'},
      {:'==', entity, :'$1'},
      {:'==', key, :'$3'}}],
      [:'$1'] }]
    |> has?()
  end

  defp delete(object) do
    object
    |> Selection.values()
    |> Stream.each(&(ED.delete(&1)))
    |> Stream.run
  end

  defp has?(match_spec) do
    match_spec
    |> ED.select()
    |> Selection.values()
    |> length() > 0
  end
end