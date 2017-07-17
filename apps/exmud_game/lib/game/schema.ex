defmodule Exmud.Game.Schema do
  import Exmud.Game.SchemaHelpers

  def callbacks do
    # These are global callbacks. There may be many more callbacks in use than are defined here,
    # and more global callbacks can be added dynamically, but this is a clear central place to provide
    # sane defaults that will be loaded and cached on engine initialization.
    [
      callback("BEFORE_PUPPET", &Exmud.Game.Callback.DefaultPuppetCallbacks.before_puppet/1),
      callback("AFTER_PUPPET", &Exmud.Game.Callback.DefaultPuppetCallbacks.after_puppet/1),
      callback("BEFORE_TRAVERSE", &Exmud.Game.Callback.DefaultTraverseCallbacks.before_traverse/1),
      callback("AFTER_TRAVERSE", &Exmud.Game.Callback.DefaultTraverseCallbacks.after_traverse/1)
    ]
  end

  def command_sets do
    # Command sets must be defined to be used by the engine.
    [
      command_set("Player", Exmud.Game.CommandSet.Player),
      command_set("Chat", Exmud.Game.CommandSet.Chat),
      command_set("Character", Exmud.Game.CommandSet.Character),
      command_set("Combat", Exmud.Game.CommandSet.Combat)
    ]
  end

  def components do
    # Components must be defined to be used by the engine. An optional argument may be provided which will
    # be passed as-is to the initialization function of the component with the option to merge or overwrite
    # with runtime provided values.
    [
      component("Player", Exmud.Game.Component.Player),
      component("Character", Exmud.Game.Component.Character),
      component("Weapon", Exmud.Game.Component.Weapon),
      component("Armor", Exmud.Game.Component.Armor)
    ]
  end

  def scripts do
    # Scripts must be defined to be used by the engine. An optional argument may be provided which will
    # be passed as-is to the initialization function of the script with the option to merge or overwrite
    # with runtime provided values.
    #
    # In addition there are a number of options that configure the runtime behavior of a script.
    [
      script("SimpleAI", Exmud.Game.Script.SimpleAI, state: %{time_factor: 2}),
      script("NatureSounds", Exmud.Game.Script.NatureSounds, delay: 500, interval: 30_000),
      script("CloseDoor", Exmud.Game.Script.NatureSounds, once: true, delay: 100)
    ]
  end

  def systems do
    # Systems must be defined to be used by the engine. An optional argument may be provided which will
    # be passed as-is to the initialization function of the system with the option to merge or overwrite
    # with runtime provided values.
    #
    # In addition there are a number of options that configure the runtime behavior of a system.
    [
      system("Invasion", Exmud.Game.System.Invasion, state: %{type: "Goblin"}, mode: :manual),
      system("Time", Exmud.Game.System.Time, state: %{time_factor: 2}, mode: :automatic),
      system("Weather", Exmud.Game.System.Weather)
    ]
  end
end