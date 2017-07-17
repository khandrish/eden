defmodule Exmud.Engine.Cache do
  import Exmud.Engine.Utils

  def delete(category, key) do
    Cachex.del(cache(), {category, key})
  end

  def exists?(category, key) do
    Cachex.exists?(cache(), {category, key})
  end

  def get(category, key) do
    Cachex.get(cache(), {category, key})
  end

  def set(category, key, callback_module) do
    Cachex.set(cache(), {category, key}, callback_module)
  end
end