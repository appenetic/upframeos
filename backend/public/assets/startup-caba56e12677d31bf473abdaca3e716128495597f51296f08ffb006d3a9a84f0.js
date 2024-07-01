document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', initialize)
    : initialize();

function initialize() {
    let video = document.getElementById('background-video');
    video.onloadeddata = function () {
        let logo = document.getElementById('logo');
        logo.style.display = 'flex';
    };
};
