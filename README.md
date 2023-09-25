# Gravity Referral Source Client 

This application is part of a reference implementation for the [Gravity FHIR
Implementation Guide](http://hl7.org/fhir/us/sdoh-clinicalcare/). It, together
with the [EHR FHIR
Server](https://github.com/Gravity-SDOHCC/gravity-sdoh-ehr-server), plays the
role of a simulated EHR which is capable as initiating referrals for SDOH
services. See [docs/usage.md](the usage documentation) for instructions on using
the RI.

## Setup
This application is built with Ruby on Rails. To run it locally, first [install
rails](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails).

* Clone this repository: `git clone
  https://github.com/Gravity-SDOHCC/sdoh_referral_source_client.git`
* Navigate to the root of this repository: `cd sdoh_referral_source_client`
* Install dependencios: `bundle install`
* Set up the database: `bundle exec rake db:setup`
* Run the application: `bundle exec rails s`
  * If you need to run the application on a different port, specify the `PORT`
    environment variable: `PORT=3333 bundle exec rails s`
* Navigate to `http://localhost:3000` in your browser

## Usage
See [the usage
documentation](https://github.com/Gravity-SDOHCC/sdoh_referral_source_client/blob/master/docs/usage.md)
for instructions on using the reference implementations.

## Known Issues
- No support for servers which require authorization
- No support for patient task/social risk assessment workflow
- Users are required to manually enter ICD-10 and SNOMED codes when adding a
  Health Concern/Problem
- Not all SDOH categories are supported when creating Goals and Referrals
- Sometimes when new links are added to the page (such as when a new referral is
  received), clicking o the link will have no effect until the page is reloaded

## License
Copyright 2023 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice
HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
