// app/javascript/packs/popovers_initializer.js
import { Popover } from 'bootstrap';

document.addEventListener('DOMContentLoaded', () => {
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new Popover(popoverTriggerEl, {
      container: '.avatar',
      html: true
    });
  });
});

