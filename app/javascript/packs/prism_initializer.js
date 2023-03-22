// app/javascript/packs/prism_initializer.js

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.modal').forEach((modal) => {
    modal.addEventListener('shown.bs.modal', () => {
      Prism.highlightAllUnder(modal);
    });
  });
});
