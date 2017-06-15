# Exmud

**Build status**

master:
[![Build Status](https://travis-ci.org/mononym/exmud.svg?branch=master)](https://travis-ci.org/mononym/exmud)
develop:
[![Build Status](https://travis-ci.org/mononym/exmud.svg?branch=develop)](https://travis-ci.org/mononym/exmud)

**Coverage status**

master:
[![Coverage Status](https://coveralls.io/repos/github/mononym/exmud/badge.svg?branch=master)](https://coveralls.io/github/mononym/exmud?branch=master)
develop:
[![Coverage Status](https://coveralls.io/repos/github/mononym/exmud/badge.svg?branch=develop)](https://coveralls.io/github/mononym/exmud?branch=develop)

**Documentation status**

master:
[![Inline docs](http://inch-ci.org/github/mononym/exmud.svg?branch=master)](http://inch-ci.org/github/mononym/exmud?branch=master)
develop:
[![Inline docs](http://inch-ci.org/github/mononym/exmud.svg?branch=develop)](http://inch-ci.org/github/mononym/exmud?branch=develop)

## Overview

Exmud is an engine for text based games with an opinionated but configurable way of doing things.

**WARNING:** Exmud is in the prototyping stage and is likely to change rapidly and dramatically without warning. It is not ready to be used. Documentation possibly outdated where it exists.

## What does it do?
* The minimum possible.
* Provides a foundation for a concurrent and parallel game world, abstracting the details away from a developer.

## What doesn't it do?
* Handle communication with the players directly.
  * The engine communicates with Elixir code only, leaving it up to the developer to implement the communication layer.
  * This is likely to change in the future.

## Using Exmud
Exmud is designed to be used as a dependency in another project, with that project providing all of the game specific logic.

To start, include as a dependency:
```elixir
defp deps do
  [{:exmud, ">= 0.0.0"}]
end
```

Add `:exmud` to the list of applications to start and then register/add/start the M.U.D. specific systems, command sets, and players to get the ball rolling. See documentation for more detailed information.

## Callback modules
The design isn't complete yet, but the gist is that there are a core set of concepts that if adhered to define the basic logical flow of a M.U.D. engine. By providing behavior definitions and API's to register callback modules with the engine, these custom bits of logic can then be executed by a solid core engine that abstracts away the logistics of executing that work. This will also allow the core engine and game specific logic to be updated independently of each other.

## Inspiration
Many of the concepts present in Exmud are inspired by or directly copied from Evennia. I wanted to do a fun project in Elixir, and as part of the preperation for that I looked at what others had done. Evennia stood out as an interesting project with a lot of solid ideas that could be adapated to fit my needs. While there has been a lot of adaptation, and there will undoubtedly be more, Evennia was definitely the go-to starting-point for several pieces of core logic.

If you're interested in something that you can get up and running now, are just curious in seeing what's cooking over in Python land, or just want to see what inspired some of the design of Exmud, I highly recommend you head on over to the [Evennia website](http://www.evennia.com/).