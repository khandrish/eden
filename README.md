# Exmud

A framework for the development and management of onlime multiplayer text-based (muds) games. 

Initially created as a port of [Evennia](http://www.evennia.com/), it has since taken on a life of its own. That said,
several core concepts borrowed from Evennia are still present.

## Installation

The package can be installed by adding `exmud` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exmud, git: "https://github.com/mononym/exmud.git"}]
end
```

## Setup

Exmud is designed to be configured/run from within the consuming application's supervision tree.

### Configure ExRedis

ExRedis is used by `Plug.Session`. For all configuration options, please see the [ExRedis GitHub page]

```elixir
config :exredis, url: System.get_env("REDIS_URL")
```

  [ExRedis GitHub page]: https://github.com/artemeff/exredis

### Configure Plug

`Plug.Session` is what manages player/browser sessions on the server side.

```elixir
plug Plug.Session,
  expiration_in_seconds: 3000, # Default is 30 days
  key: "session_id",
  store: :redis
```

### Configure Endpoint

Phoenix is the web server used by `Exmud`. For all configuration options, please see the [Phoenix Homepage]

```elixir
config :exmud, ExmudWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9W/QZ3iU5+9TFpwlAPVG1zwlO94sfqDaSn+J0l4rwMLwKfq+L7CgVAs18kOQIZ7d",
  live_view: [
    signing_salt: "eq1EMSpEwuOqxyc2o5ehOrSEg1fMGEm3"
  ]
```

  [Phoenix Homepage]: https://phoenixframework.org/

## Feature Roadmap

### 1.0

High level view:
- Single server.
- Redis used for sessions.
- Postgresql used as database.
- Web based player, admin, and developer UI built with LiveView as much as possible (and makes sense).
- Develop/manage/run multiple MUD's at the same time.

Authentication/Authorization:
- [x] Authentication/Registration via email.
- [] Role based account level permissions.

MUD Engine:
- [x] Everything is an Object.
- [] Composable Command Sets for dynamic behaviours.
- [] Permissions for Object access in the form of Locks.
- [] Objects can be arbitrarily linked together.
- [] Tags, which act as a truth check. Either the tag is there or it isn't.
- [] Scripts are pieces of logic which can be "attached" to Objects and executed in their own process.
- [] Systems are like Scripts, but aren't attached to any specific Object and work instead on a MUD mud level.
- [] Components encapsulate key/value pairs and are attached to each object.
- [] Object templating system, complete with Object factory and.
- [] Area/Region system built ontop of Objects/Components to make building worlds easier.
- [] Character system built ontop of Objects/Components to make certain things easier.
- [] Telemetry of as much of the system as possible
- [] Players can connect to one character on one MUD, one each on multiple muds, or multiple characters based on config
- [] Events emitted for almost everything, account creation/deletion or player login/logout for example

### 2.0

- [] Forums
- [] Wiki
- [] Store
- [] Subscriptions
- [] Scripting engine/system
- [] Stream game events to browser

## License

Exmud is released under the MIT License - see the [LICENSE](LICENSE) file.
