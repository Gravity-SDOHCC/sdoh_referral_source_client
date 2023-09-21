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

### Initiating a referral in the referral source client

In the referral source client, you can view and add to a Patient's Observations,
Conditions, and Goals. There is also a tab to manage the organizations to which
you can refer a Patient. To initiate a referral, navigate to the Action Steps
tab and click the button to add a referral. If the Organization the Patient is
being referred to has a FHIR server url listed, the normal referral workflow
will be used. If the Organization does not have a FHIR server url listed, then
the referral will use the light workflow. As the referral moves through the
workflow, its status will be automatically updated on the Action Steps tab.

### Forwarding a referral in the coordination platform client

The coordination platform (CP) is responsible for receiving referrals from a
referral source, and forwarding them to an Organization which complete the
referral (this is the Indirect referral workflow). The CP client has a Community
Based Organizations tab for managing the list of Organizations which the CP can
forward referrals to. The CP is currently represented by the `ABC Coordination
Platform` Organization in the referral source client. If a referral is made to
this Organization, it will automatically appear in the list of Service Requests
in the CP client.

Once a task has appeared in the CP client, the referral can be accepted and
forwarded to one of the Organizations listed in the Community Based
Organizations tab. Once that Organization completes the referral, the CP client
can mark the original referral as completed.

### Receiving a referral in the community based organization client

The CBO client acts as a client for the recipient of a referral using the light
referral workflow. As such, it has no FHIR server of its own, but instead
connects to the FHIR server belonging to the referral source to query for
referrals. This could be the RI EHR Server for referrals coming directly from
the referral source client, or the RI CP Server for referrals coming from the RI
Coordination Platform. Once the CBO client connects to a FHIR server, you will
have to select which Organization the client is representing, and the client
will fetch referrals for that Organization. The referrals can be accepted and
their status can be updated until they are finally marked as completed. The CP
and referral source clients will both display the referral status as it is
updated in the CBO client.

## Recovering from Errors

If an unexpected error occurs and one of the RI client apps is stuck in a bad
state, you can reset your session by visiting `/disconnect`. If the problem is
caused by bad data on the server the client is connecting to, then the bad data
on the server will need to be fixed.
