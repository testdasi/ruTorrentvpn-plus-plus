## I gave up haha
I tried to edit binhex's scripts to trigger ovpn picker when port-forwarding fails. Spent some hours trying it but lost interest as it's too complicated for me.
The key complication is that the ovpn cleanup script (start.sh) is triggered before it sources the ovpn connection script. So I have to figure out a way to go back after the ovpn trigger.
