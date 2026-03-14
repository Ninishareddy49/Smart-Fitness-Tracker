// SmartFit PRO - Minimal JS for polish
document.addEventListener('DOMContentLoaded', () => {

  // Trigger Plotly resize when tab switches (Shiny swaps panels on nav click)
  $(document).on('shown.bs.tab', function() {
    setTimeout(() => window.dispatchEvent(new Event('resize')), 150);
  });

  // Re-render Plotly charts when Shiny finishes recalculating
  $(document).on('shiny:value', function() {
    setTimeout(() => window.dispatchEvent(new Event('resize')), 200);
  });

});
