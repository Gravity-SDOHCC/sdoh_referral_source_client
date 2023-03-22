// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap";
import "@popperjs/core";
import 'prismjs';
import 'prismjs/themes/prism.css';
import './prism_initializer';
import '../../assets/stylesheets/application.scss';

Rails.start()
Turbolinks.start()
ActiveStorage.start()

require("jquery");
