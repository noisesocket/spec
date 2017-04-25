

5. API
=======

 * **`ReadString(buffer)`**  reads 1 byte `len` of the following string from `buffer` and then `len` bytes string itself. Advances read position to `len + 1`

 * **`WriteString(string, buffer)`** writes 1 byte `len` of the following string to `buffer` and then string itself.

 * **`ReadData(buffer)`** reads 2 byte `len` of the following data from `buffer` and then `len` bytes of data. Advances position to `len + 2`

 * **`WriteData(data, buffer)`** writes 2 bytes `len` of the following data to `buffer` and then the data itself.

 * **`CalculatePrologue(protocols)`** takes a list of protocol names in the order they will be used in the handshake.
 
 	* Variables:
 	* **`prologue_buffer`** - a byte buffer to write to

 	* Writes 1 byte number of protocols `N` to `prologue_buffer`
 	* Does `N` times:
 		* Takes the next `protocol_name` from `protocols`
 		* Calls `WriteString(protocol_name, prologue_buffer)`

 	 * Returns:
 		* `prologue_buffer`

 * **`ComposeInitiatorHandshakeMessages(s, data, protocols)`** takes client's static key `s`, optional payload `data` and a list of protocols, same that was used for caling `CalculatePrologue`
 	Variables
 		* **`result_buffer`** - buffer, containing the resulting byte sequence
 		* **`message_buffer`** - temporary buffer to hold the result of calling `WriteMessage` on the current `handshake_state`
 		* **`handshake_states`** - an array of all instances of `HandshakeState` objects, created during this method

 	* Calls `CalculatePrologue(protocols)` to receive `prologue`
 	* Writes the 1 byte number of protocols `N` to `result_buffer`
 	* Does `N` times
 		* Takes the next `protocol` from `protocols`
 		* Calls `WriteString(protocol_name, result_buffer)`
 		* Calls `GENERATE_KEYPAIR()` to generate new `e`
 		* Initializes new `HandshakeState` instance with `DH functions`, `Cipher functions` and `Hash functions`, described in `protocol` and also `s`, `e` and `prologue` to receive `handshake_state`
 		* initializes new `message_buffer`
 		* Calls `WriteMessage(data, message_buffer)` on `handshake_state`
 		* Calls `WriteData(message_buffer, result_buffer)`
 		* Adds `handshake_state` to `handshake_states`

 	* Returns:
 		* `result_buffer`
 		* `handshake_states`

 * **`ParseFirstMessage(message, s)`** receives `message`, created by calling `ComposeInitiatorHandshakeMessages` and static keypair `s`
 	Variables:
 		* **`protocols`** - a list of protocol names, parsed from `message`
 		* **`sub_messages`** - a list of byte sequences in order they were written to `message` by calling `WriteMessage`
 		* **`handshake_state`** - a state that was created when server chose one of the incoming messages
 		* **`message_index`** - an index of the message that server chose
 		* **`payload`** - an optional payload, provided in the first message

 	* Reads the number of sub-messages `N`
 	* Does `N` times:
 		* Calls `ReadString(message)` to receive `protocol_name`
 		* Calls `ReadData(message)` to receive `sub_message`
 		* Appends `protocol_name` to `protocols`
 		* Appends `sub_message` to `sub_messages`
 	* Calls `CalculatePrologue(protocols)` to receive `prologue`
 	* Chooses a protocol, according to server protocol priority and the corresponding `sub_message` from `sub_messages`. 
 	* Writes index of the chosen `protocol` to `message_index`
 	* Calls `GENERATE_KEYPAIR()` to generate new `e`
 	* Initializes new `HandshakeState` instance with `DH functions`, `Cipher functions` and `Hash functions`, described in `protocol` and also `s`, `e` and `prologue` to receive `handshake_state`
 	* Calls `ReadMessage(sub_messages)` on `handshake_state` to receive an optional `payload`

 	* Returns:
 		* `message_index`
 		* `handshake_state`
 		* `payload`


 * **`ComposeServerResponseMessage(handshake_state, index, data)`** receives `handshake_state`, `index` and optional `data` to send to client

 	Variables
 		* **`result_buffer`** - buffer, containing the resulting byte sequence


 	* Writes `index` to `result_buffer`
 	* Calls WriteMessage(result_buffer, data) on handshake_state

 	Returns:
 		`result_buffer`
   
   
