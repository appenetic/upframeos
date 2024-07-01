document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', initialize)
    : initialize();

function initialize() {
    let video = document.getElementById('background-video');
    video.onloadeddata = function () {
        let logo = document.getElementById('logo');
        logo.style.display = 'flex';
    };

    // Set a timeout to redirect after 60 seconds (60000 milliseconds)
    setTimeout(function() {
        window.location.href = '/'; // Replace '/desired-url' with the actual path you want to redirect to
    }, 60000); // 60000 milliseconds equals 1 minute
};
