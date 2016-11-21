# Exmud

[![Build Status](https://travis-ci.org/mononym/exmud.svg?branch=master)](https://travis-ci.org/mononym/exmud)
[![Inline docs](http://inch-ci.org/github/mononym/exmud.svg)](http://inch-ci.org/github/mononym/exmud)

Exmud is a framework and game agnostic M.U.D. engine.

**WARNING:** Exmud is in the prototyping stage and is likely to change rapidly and dramatically without warning. It is not ready to be used. Documentation is sparse and possibly outdated.

## What does framework agnostic mean?
It means that in an effort to, among other things, limit the scope the following restrictions are in place:
* All communication with the engine must be done through a well defined API.
  * The API will be restricted to Elixir functions provided in API modules.
* Beyond providing the API modules, it is up to developers to decide how to integrate with their application which communicates with everything not the engine.
* The engine must only implement the core logic necessary to the running of the engine. Everything else must be delegated and configurable, with well defined API's and protocols for communicating between pieces.
  * There will be no built in systems, world, or game logic of any kind. Any example projects are out of scope and will come in another package.

**NOTE:** The above list is is need of updating and refinement. 

## Using Exmud
Exmud is designed to be used as a dependency in another project, with that project providing all of the game specific logic.

To start, include as a dependency:
```elixir
defp deps do
  [{:exmud, ">= 0.0.0"}]
end
```

Add `:exmud` to the list of applications to start and then register/add/start the M.U.D. specific systems, command sets, and players to get the ball rolling. See documentation for more detailed information.

## Callback modules?
The design isn't complete yet, but the gist is that there are a core set of concepts that if adhered to define the basic logical flow of a M.U.D. engine. By providing behavior definitions and API's to register callback modules with the engine, these custom bits of logic can then be executed by a solid core engine that abstracts away the logistics of executing that work. This will also allow the core engine and game specific logic to be updated independently of each other.
