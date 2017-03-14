---
title:      'The Noise Socket Protocol'

---


1. Introduction
================

Noise Socket is a secure transport layer protocol that is much simplier than TLS,
easier to implement.
The communicating parties are identified by raw public keys, with the option to provide certificates during the
initial handshake


It is useful in IoT, as TLS replacement in microservice architecture, messaging
and other cases where TLS looks overcomplicated.


It is based on the [Noise protocol framework](http://noiseprotocol.org) which
internaly uses only symmetric ciphers, hashes and DH to do secure handshakes.

2. Overview 
============ 
Noise Socket describes how to compose and parse handshake and transport messages, do versioning and negotiation.
There is only one mandatory pattern that must be present in any first handshake message: [Noise_XX](http://noiseprotocol.org/noise.html#interactive-patterns).
Noise_XX allows any combination of authentications (client, server, mutual, none) by using null
public keys (i.e. sending a public key of zeros if you don't want to authenticate).

Other patterns may be supported by concrete implementations, for example Noise_IK can be used for 0-RTT if client knows server's public key. But at least one Noise_XX message must be included first in any first message

Traffic in Noise Socket is split into packets each less than or equal to 65535 bytes (2^16 - 1) which allows for easy parsing and memory management.

All sizes are in big endian form.

3. Handshake packet structure
---------------------------

- 2 bytes packet size (Ps)
- data

```
=====PACKET====
[Ps] | [data] 
      =PAYLOAD=
```

4. Handshake packets
---------------------------

The handshake process consists of set of messages which client and server send to each other. First two of them have a specific payload structure

In the **First handshake message** client offers server a set of sub-messages, each of which corresponds to a concrete [Noise protocol](http://noiseprotocol.org/noise.html#protocol-names)

Each handshake sub-message contains following fields:
   - 1 byte length of the following string, indicating the ciphersuite/protocol used, i.e. message type (Tl)
   - L bytes string indicating message type (T)
   - 2 bytes big-endian length of following Noise message (Ml)
   - **Noise message** (M)

**Noise message** is received by calling **WriteMessage** on the corresponding [HandshakeState](http://noiseprotocol.org/noise.html#the-handshakestate-object)

First handshake message full structure:
```
=================PACKET=============================================================================
[2 bytes len] | ...N times... ([ 1 byte Tl] [T] [Ml] [M])
                ====================================PAYLOAD=========================================
```

 
In the **Second handshake message** server responds to client with the following structure

Second packet structure:
 - 1 byte index of the message that responder responds to
 - 1 byte message type it sends in case server supports noise pipes. See section [9.2](http://noiseprotocol.org/noise.html#compound-protocols-and-noise-pipes) of the original doc. 0 if server accepted IK message, 1 if it started XX_Fallback
 - **Noise message**
 
 
Second handshake message full structure:
 ```
=================PACKET=============================================================================
[2 bytes len] | [1 byte index] [handshake message]
                ====================================PAYLOAD=========================================
```

After client gets server response there's no longer need in extra transport fields, so all following packets have the following structure:

 ```
=================PACKET=============================================================================
[2 bytes len] | [handshake nessage]
                ====================================PAYLOAD=========================================
```
 
 
3 messages are needed to be sent and received to implement full Noise_XX handshake.
2 mesages  are needed to be sent and received to implement full Noise_IK handshake.

5. Prologue
---------------------
Noise [prologue](http://noiseprotocol.org/noise.html#prologue) is calculated as follows:
- 1 byte amount of message types (N)
- N times:
  -- 1 byte message type length (L)
  -- L bytes message type (Noise protocol string)

<details> 
 <summary>An example of such prologue would be: (expand to view in HEX) </summary>
101c4e6f6973655f58585f32353531395f41455347434d5f5348413235361d4e6f6973655f58585f32353531395f41455347434d5f424c414b4532621c4e6f6973655f58585f32353531395f41455347434d5f5348413531321d4e6f6973655f58585f32353531395f41455347434d5f424c414b453273204e6f6973655f58585f32353531395f436861436861506f6c795f534841323536214e6f6973655f58585f32353531395f436861436861506f6c795f424c414b453262204e6f6973655f58585f32353531395f436861436861506f6c795f534841353132214e6f6973655f58585f32353531395f436861436861506f6c795f424c414b4532731c4e6f6973655f494b5f32353531395f41455347434d5f5348413235361d4e6f6973655f494b5f32353531395f41455347434d5f424c414b4532621c4e6f6973655f494b5f32353531395f41455347434d5f5348413531321d4e6f6973655f494b5f32353531395f41455347434d5f424c414b453273204e6f6973655f494b5f32353531395f436861436861506f6c795f534841323536214e6f6973655f494b5f32353531395f436861436861506f6c795f424c414b453262204e6f6973655f494b5f32353531395f436861436861506f6c795f534841353132214e6f6973655f494b5f32353531395f436861436861506f6c795f424c414b453273
</details>


6. Handshake payload protection
---------------------
 - During XX handshake, only second and third messages may contain payloads. The first wold be sent in clear
 - During IK handshake, first and second messages may contain payloads.
 
7. Data packets
---------------------

After handshake is complete and both [Cipher states](http://noiseprotocol.org/noise.html#the-cipherstate-object) are created, all following packets must be encrypted.

The maximum amount of plaintext data that can be sent in one packet is

```
65535 - 4(header size) - 16 (mac size) = 65515 bytes
```

8. Payload fields
---------------------------
Each encrypted handshake payload as well as every encrypted transport message consists of 1 or more fields.
Every field has the following structure:

 - 2 byte Size (including type)
 - 2 byte Sub-message type
 - Contents
 
 
The minimum field size is 4 bytes (0 bytes of field payload data).  The total size of all fields must not exceed Ps - MACsize.
 
 Each Noise Socket implementation must support the following two message sub-types:
 
 `0: Padding`
 
 `1: Primary data channel`

The minimum field size is 4 bytes (0 bytes of field payload data).  The total size of all fields must not exceed Ps - MACsize.

Message types 0 to 1023 are reserved for use in this and future versions of the NoiseSocket specification.  Message types 1024 to 65535 are application-defined.

This version of the specification defines message type **0** as padding.  The field payload data is ignored and should contain random bytes.  If the overall message length would have 1 to 3 bytes left over once all fields are parsed, those bytes will also contain random padding without a field header.

Message type **1** is assigned to the primary data channel within the session if the application does not have its own way of identifying separate channels.

A minimal implementation of NoiseSocket supports message types 0 and 1 to provide a TLS-style transparent data link.  More complex applications may forbid the use of message type 1 and use their own message types for identifying separate channels of communication.  Padding must always be supported.

This format is also used in handshake message payloads if the payload size is non-zero.

9. Re-keying
-------------------

...
