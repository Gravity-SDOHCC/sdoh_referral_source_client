# Using the Gravity Reference Implementation

The Gravity reference implementation consists of applications and servers which
together are capable of performing the [closed loop referral
workflows](http://hl7.org/fhir/us/sdoh-clinicalcare/referral_workflow.html)
described in the [Gravity SDOH Clinical Care
IG](http://hl7.org/fhir/us/sdoh-clinicalcare/index.html).

## Components

The reference implementation contains the following components:

* [Referral Source
  Client](https://github.com/Gravity-SDOHCC/sdoh_referral_source_client) - a web
  app that acts as a simulated EHR UI capable of initiating referrals
* [EHR Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-ehr-server) - a
  FHIR server which stores data for the referral source client
* [Coordination Platform
  Client](https://github.com/Gravity-SDOHCC/sdoh_coordination_platform_client) -
  a web app which acts as a UI for coordination platform which receives
  referrals from an EHR system and sends them to CBOs
* [Coordination Platform
  Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-cp-server) - a FHIR
  server which stores data for the coordination platform
* [CBO Client](https://github.com/Gravity-SDOHCC/sdoh_cbo_client) - a web app
  which acts as a UI for a Community Based Organization which receives and
  completes referrals

## Usage
