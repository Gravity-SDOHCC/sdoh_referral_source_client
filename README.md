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

# TODO:
- [ ] Add authentication
- [ ] create race, sex gender, sexual orientation, & gender identity personal characteristics
- [ ] Goals (Goal resource) addresses health concerns/problems (Condition)
- [ ] read, delete health concerns, and promote to problems
- [ ] read problems
- [ ] read, create, complete goals
- [ ] read, create, cancel referral management tasks (Action steps), also poll for status update
- [ ] read, create, cancel, patient tasks, also poll for status update
- [ ] social risk assessment workflow
- [ ] fix view fhir_resource modal
- [ ] fix logout popover link not showing when in patient page (when displaying single patient info)
- [ ] complete upper level menu (showing the list of org recipients, ...)
- [ ] switch flash bootstrap alert to toast (live toast)

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
