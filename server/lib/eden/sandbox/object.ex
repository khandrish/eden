defmodule Eden.Sandbox.Object do
  alias Eden.Object
  
  def new do
  	#%Object{}
  	nil
  end

  def get_key(object) do
  	object.key
  end

  def set_key(object, key) do
  	%{object | key: key}
  end

  def get_date_created(object) do
  	object.inserted_at
  end

  def get_last_update(object) do
  	object.updated_at
  end

  def get_id(object) do
  	object.id
  end

  def get_aliases(object) do
  	HashSet.to_list(object.aliases)
  end

  def has_alias(object, alias) do
  	HashSet.member?(object.aliases, alias)
  end

  def add_alias(object, alias) do
  	%{object | aliases: HashSet.put(object.aliases, alias)}
  	|> dirty
  end

  def delete_alias(object, alias) do
  	%{object | aliases: HashSet.delete(object.aliases, alias)}
  	|> dirty
  end

  def clear_aliases(object) do
  	%{object | aliases: HashSet.new}
  	|> dirty
  end

  def get_property(object, property, default \\ nil) do
  	Map.get(object.properties, property, default)
  end

  def has_property(object, property) do
  	Map.has_key?(object.properties, property)
  end

  def add_property(object, property, value) do
  	%{object | properties: Map.put(object.properties, property, value)}
  	|> dirty
  end

  def delete_property(object, property) do
  	%{object | properties: Map.delete(object.properties, property)}
  	|> dirty
  end

  def clear_properties(object) do
  	%{object | properties: %{}}
  	|> dirty
  end

  def save(object)do
  	Repo.insert! object
  end

  #def save(object) do
  #	object
  #end

  defp dirty(object) do
  	%{object | dirty: true}
  end
end
