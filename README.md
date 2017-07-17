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

Exmud is a toolkit for building, running, and managing multiplayer online text based games. The web interface is provided by Phoenix, and will be where everything other than building the code for the game takes place, from adding/removing/banning players to building up the content of the world.

**WARNING:** Exmud is in the prototyping stage and is likely to change rapidly and dramatically without warning. It is not ready to be used. Documentation is sparse and possibly outdated.

## Using Exmud
There is no guidance on this yet. The rough image in mind is for the repo to be forked/cloned, with game development happening in one of the Elixir apps designated for that. The reason for this is that it will provide full access to both the Phoenix web app as well as the engine itself. In this way anyone can make any modifications they need to make Exmud theirs and work for them, while maintaining a link to the original repo will allow for updates and bug fixes to the engine to make their way into the customized code base.

## Inspiration
Many of the concepts present in Exmud are inspired by or directly copied from Evennia. I wanted to do a fun project in Elixir, and as part of the preperation for that I looked at what others had done. Evennia stood out as an interesting project with a lot of solid ideas that could be adapated to fit my needs. While there has been a lot of adaptation, and there will undoubtedly be more, Evennia was definitely the go-to starting-point for several pieces of core logic.

If you're interested in something that you can get up and running now, are just curious in seeing what's cooking over in Python land, or just want to see what inspired some of the design of Exmud, I highly recommend you head on over to the [Evennia website](http://www.evennia.com/).