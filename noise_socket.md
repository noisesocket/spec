---
title:      'The Noise Socket Protocol'

---


**1. Introduction**
---------------------------

Noise Socket is a secure transport layer protocol that is much simpler than TLS and easier to implement.
The communicating parties are identified by raw public keys, with the option to provide certificates during the
initial handshake


It is useful in IoT, as TLS replacement in microservice architecture, messaging
and other cases where TLS looks overcomplicated.


It is based on the [Noise protocol framework](http://noiseprotocol.org) which
internally uses only symmetric ciphers, hashes and DH to do secure handshakes.

**2. Overview** 
---------------------------
Noise Socket describes how to compose and parse handshake and transport messages, do versioning and negotiation.
There is only one mandatory pattern that must be present in any first handshake message: [Noise_XX](http://noiseprotocol.org/noise.html#interactive-patterns).
Noise_XX allows any combination of authentications (client, server, mutual, none) by using null
public keys (i.e. sending a public key of zeros if you don't want to authenticate).

Other patterns may be supported by concrete implementations, but at least one Noise_XX message must be included first in any first message

Traffic in Noise Socket is split into packets each less than or equal to 65535 bytes (2^16 - 1) which allows for easy parsing and memory management.

All sizes are in big endian form.

**3. Packet structure**
---------------------------

Both handshake and transport packets have the following structure:

* 2 bytes packet size 
* Data


**4. Handshake packets**
---------------------------

The handshake process consists of set of messages which client and server send to each other. First two of them have a specific data structure


**4.1. First handshake message** 
---------------------------
In the **First handshake message** client offers server a set of sub-messages, identified by a string name. For example, [Noise protocol](http://noiseprotocol.org/noise.html#protocol-names).

Each handshake sub-message contains following fields:
   * 1 byte length of the following string, indicating the ciphersuite/protocol used, i.e. message type
   * String indicating message type
   * 2 bytes big-endian length of following sub-message 
   * **Sub message**

When using Noise, **Sub message** is received by calling **WriteMessage** on the corresponding [HandshakeState](http://noiseprotocol.org/noise.html#the-handshakestate-object)

**4.2. Second handshake message**
------------------------- 
In the **Second handshake message** server responds to client with the following structure:
* 1 byte sub-message index server responds to
* Handshake message


**5. Prologue**
---------------------
Noise [prologue](http://noiseprotocol.org/noise.html#prologue) is calculated as follows:
* 1 byte number of message types (N)
* N times:
  * 1 byte message type length
  * Message type (ex. Noise protocol string)

An example of such prologue could be found in Appendix

**6. Data packets**
---------------------

After handshake is complete and both [Cipher states](http://noiseprotocol.org/noise.html#the-cipherstate-object) are created, all following packets must be encrypted using those cipherstates.


**Appendix**
------------------
<details> 
 <summary>An example prologue: (expand to view in HEX) </summary>
101c4e6f6973655f58585f32353531395f41455347434d5f5348413235361d4e6f6973655f58585f32353531395f41455347434d5f424c414b4532621c4e6f6973655f58585f32353531395f41455347434d5f5348413531321d4e6f6973655f58585f32353531395f41455347434d5f424c414b453273204e6f6973655f58585f32353531395f436861436861506f6c795f534841323536214e6f6973655f58585f32353531395f436861436861506f6c795f424c414b453262204e6f6973655f58585f32353531395f436861436861506f6c795f534841353132214e6f6973655f58585f32353531395f436861436861506f6c795f424c414b4532731c4e6f6973655f494b5f32353531395f41455347434d5f5348413235361d4e6f6973655f494b5f32353531395f41455347434d5f424c414b4532621c4e6f6973655f494b5f32353531395f41455347434d5f5348413531321d4e6f6973655f494b5f32353531395f41455347434d5f424c414b453273204e6f6973655f494b5f32353531395f436861436861506f6c795f534841323536214e6f6973655f494b5f32353531395f436861436861506f6c795f424c414b453262204e6f6973655f494b5f32353531395f436861436861506f6c795f534841353132214e6f6973655f494b5f32353531395f436861436861506f6c795f424c414b453273
</details>

**Test vectors**
------------------

Initial message is moved to the root to reduce the file size. It contains 16 sub-messages each correspond to a specific Noise protocol. The order of protocols can be seen in [Protocols] array.

"Server" chooses which sub-message to answer and this forms a session. 
Each session contains an array of transport messages which consist of raw wire data ("Packet" field), payload and fields

"Payload" is the representation of Noise socket fields in the order they appear in nonempty message payload. It may or may not be present during handshake (1st XX message has always an empty payload).

Nonempty payload contains 1 or more fields. There's one field during handshake (dummy type 1024) and two (0 - data and 1 - padding) for transport messages.
