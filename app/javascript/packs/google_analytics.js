document.addEventListener("DOMContentLoaded", () => {
  if (document.body.dataset['ga'])
  {
    if (typeof gtag === 'function') {
      gtag('config', document.body.dataset.ga, {
        'page_location': window.location.href,
        'page_path': window.location.pathname
      })
    }
  }
});
