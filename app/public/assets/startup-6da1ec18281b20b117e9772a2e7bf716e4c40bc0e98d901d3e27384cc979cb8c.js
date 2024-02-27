window.onload = function(){
    setTimeout(function() {
        document.getElementById('logo').style.opacity = 0;
    }, 5000);
};

document.addEventListener('DOMContentLoaded', function() {
    let video = document.getElementById('background-video');
    video.onloadeddata = function() {
        let logo = document.getElementById('logo');
        logo.style.display = 'flex';
    };
});
