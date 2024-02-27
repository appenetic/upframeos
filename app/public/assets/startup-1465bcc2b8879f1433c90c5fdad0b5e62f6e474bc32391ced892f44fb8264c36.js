window.onload = function() {
    setTimeout(function() {
        document.getElementById('logo').style.opacity = 0;
    }, 5000);
};

document.addEventListener('DOMContentLoaded', function() {
    var video = document.getElementById('background-video');
    video.onloadeddata = function() {
        var logo = document.getElementById('logo');
        logo.style.display = 'block'; // Show the logo once the video is loaded
    };
});
