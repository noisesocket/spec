---
title:      'The NoiseLink Protocol'
author:     'Alexey Ermishkin (scratch@virgilsecurity.com)'
revision:   '0draft'
date:       '2017-07-12'
bibliography: 'my.bib'
link-citations: 'true'
csl:        'ieee-with-url.csl'
---

**Abstract**
========================

NoiseLink (ex. NoiseSocket) is an extension of the Noise Protocol Framework 
(developed by the authors of Signal and currently used by WhatsApp) that enables quick and seamless secure link
between multiple parties with minimal code space overhead, small keys, and extremely fast speed.
NoiseLink is designed to overcome the shortcomings of existing TLS implementations and targets IoT devices, 
microservices, back-end applications such as datacenter-to-datacenter communications, and use cases where third-party 
certificate of authority infrastructure is not optimal.





1. Messages
========================

There are two types of messages which differ by structure:

   * Section [1.1](handshake-message) Handshake message
   * Section [1.2](transport-message) Transport message
   

1.1. Handshake message
--------------------------------
 
For the simplicity of processing, all handshake messages have identical structure all handshake messages have the following structure:

 - negotiation_data_len (2 bytes)
 - negotiation_data
 - noise_message_len (2 bytes)
 - noise_message


They are sent according to the corresponding Noise protocol. For example, to implement Noise_XX we need to send 3 messages:

 -> ClientHello
 <- ServerAuth
 -> ClientAuth
 
For Noise_IK we need to send 2 messages

 -> ClientHello
 <- ServerAuth


1.1.1. Negotiation data
-----------------------

The negotiation_data field is used to identify the protocols used, versions, signs of using a fallback protocol
and other data that must be processed before reading the actual noise_message.

Though it can be present in every handshake message, it can safely be used only when it is included into the 
Noise handshake through Prologue or other mechanisms like calling MixHash()


1.2. Transport message
------------------------- 

Each transport message has a special 'data_len' field inside its plaintext payload,
which specifies the size of the actual data. Everything after the data is considered padding.
65517 is the max value for data_len:
65535 (noise_message_len) - 16 (for authentication tag) - 2 (for
data_len field itself)

The encrypted packet has the following structure:


 - packet_len (2 bytes)
 - encrypted data

Plaintext payload has the following structure:

 - data_len (2 bytes)
 - data
 - remaining bytes: padding


2. Prologue
===============
  
Client uses following extra data and fields from the first message to calculate the Noise prologue:
 
 - "NoiseLinkInit" string
 - negotiation_data_len
 - negotiation_data
 
 
If server decides to start a new protocol instead of responding to the first handshake message, it calculate the Noise
prologue using the **full first message contents** plus the length and negotiation_data of its own response. 
String identifier also changes to "NoiseLinkReInit".

Thus the prologue structure:

 - "NoiseLinkReInit" string
 - negotiation_data_len
 - negotiation_data
 - noise_message_len
 - noise_message
 - negotiation_data_len
 - negotiation_data

5. API
======

ReadHandshakeMessage 

WriteHandshakeMessage

 

7. IPR
========

The NoiseLink specification (this document) is hereby placed in the public domain.

\pagebreak

8.  References
================