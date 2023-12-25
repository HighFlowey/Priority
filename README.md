# Priority5
Priority based state machine, mostly used for fighting games where you have alot of features that change a humanoid's walkspeed and jumppower.

# About version 0.5.0
This version is very similar to 0.3.0 aka. Priority3 because from my experience, Priority3 was just easier to use than Priority4.

Also, this version does not replicate states between server and client, you would have to do that manually by creating your own wrapper.

# New features
### Weight
> You can use it to put weight on the properties that are getting applied by the priority based states, for example: you can make walkspeed 2x slower no matter what state the player is in, this could be used to lower player's speed when they are swinging a weapon.