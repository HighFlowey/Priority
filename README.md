# Priority5
Priority based state machine, mostly used for fighting games where you have alot of features that change a humanoid's walkspeed and jumppower.

# Installing with wally
```
Priority = "highflowey/priority@0.5.6"
```

# Installing with git
Clone the github repo and rename the src folder to Priority then use rojo to convert it to a Roblox model.

# About version 0.5.x
This version is very similar to 0.3.x aka. Priority3 because from my experience, Priority3 was just easier to use than Priority4.

Also, this version does not replicate states between server and client, you would have to do that manually by creating your own wrapper.

# API Documents
https://highflowey.github.io/Priority/api/

# New features
### Weight
> You can use it to put weight on the properties that are getting applied by the priority based states, for example: you can make walkspeed 2x slower no matter what state the player is in, this could be used to lower player's speed when they are swinging a weapon.
