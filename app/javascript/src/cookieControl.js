export default function () {
  var onPageStyle = "#ccc-button-holder{display:none;}"
  var style = document.createElement('style');
  style.innerHTML = onPageStyle;
  document.head.appendChild(style);
}
