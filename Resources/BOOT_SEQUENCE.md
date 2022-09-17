# BOOT SEQUENCE

#### NOTES:

- SatServer is the server and SatReceiver is the client, but the normal  terminology is reversed.

- Therefore, the server will send requests and the client will respond.

- SatServer is already waiting for SatReceiver to connect.
- SatReceiver can't open the FIFO until longmynd has started

### A sequence starts when the user turns on the 12 volt power supply.

- SatController sends a command to switch ON the 12v PSU.

- SatReceiver boots and tries to connect to SatServer as a client.

- SatServer accepts the connection and starts lisening for responses.

- SatReceiver starts listening for requests and begins sending blank status data.

- SatServer sets the UI to online and sends CONFIG with current rx data.

- SatReceiver receives CONFIG and executes the re-config sequence

-


### User switches OFF the 12v PSU

- SatController sends a command to switch OFF the 12v PSU.

- SatServer enters a 12v PSU switch off sequence.
