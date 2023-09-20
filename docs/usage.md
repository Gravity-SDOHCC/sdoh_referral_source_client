# Using the Gravity Reference Implementation

The Gravity reference implementation consists of applications and servers which
together are capable of performing the [closed loop referral
workflows](http://hl7.org/fhir/us/sdoh-clinicalcare/referral_workflow.html)
described in the [Gravity SDOH Clinical Care
IG](http://hl7.org/fhir/us/sdoh-clinicalcare/index.html).

## Components

The reference implementation contains the following components:

### Clients

* [Referral Source
  Client](https://github.com/Gravity-SDOHCC/sdoh_referral_source_client) - a web
  app that acts as a simulated EHR UI capable of initiating referrals
* [Coordination Platform
  Client](https://github.com/Gravity-SDOHCC/sdoh_coordination_platform_client) -
  a web app which acts as a UI for coordination platform which receives
  referrals from an EHR system and sends them to CBOs
* [CBO Client](https://github.com/Gravity-SDOHCC/sdoh_cbo_client) - a web app
  which acts as a UI for a Community Based Organization which receives and
  completes referrals using the light referral workflow

### FHIR Servers

* [EHR Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-ehr-server) - a
  FHIR server which stores data for the referral source client
* [Coordination Platform
  Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-cp-server) - a FHIR
  server which stores data for the coordination platform

## Usage

The first step when running one of the clients is to connect to a FHIR server. A
list of available servers will be displayed, and new servers can be added to the
list if necessary. The [EHR
Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-ehr-server) was created
for the [Referral Source
Client](https://github.com/Gravity-SDOHCC/sdoh_referral_source_client) to
connect to, and the [Coordination Platform
Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-cp-server) was created
for the [Coordination Platform
Client](https://github.com/Gravity-SDOHCC/sdoh_coordination_platform_client) to
connect to. The [CBO Client](https://github.com/Gravity-SDOHCC/sdoh_cbo_client)
can connect to either server, depending on whether it is playing the role of a
CBO receiving a referral from the EHR or from the coordination platform.

## Recovering from Errors

If an unexpected error occurs and one of the RI client apps is stuck in a bad
state, you can reset your session by visiting `/disconnect`. If the problem is
caused by bad data on the server the client is connecting to, then the bad data
on the server will need to be fixed.
