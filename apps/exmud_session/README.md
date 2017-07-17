# Exmud.Session

The Session application manages the lifecycle of Player connections to the Engine. Not only are they the link between the Engine and the Player, Sessions are also responsible for managing incoming/outgoing messages so the Engine can be ignorant of and disconnected from the mechanisms of marshalling and sending data.