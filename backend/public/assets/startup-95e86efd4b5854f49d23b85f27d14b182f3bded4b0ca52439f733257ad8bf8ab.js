document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', initialize)
    : initialize();

function initialize() {
    let video = document.getElementById('background-video');
    video.onloadeddata = function () {
        let logo = document.getElementById('logo');
        logo.style.display = 'flex';
    };

    // Read the feature flag from the data attribute of the body element
    const featureEnabled = document.body.getAttribute('data-spotify-yam-feature') === 'true';

    log(featureEnabled)

    // Set a timeout to redirect based on the feature flag
    setTimeout(function() {
        // Redirect to '/spotify/yam' if feature is enabled, otherwise to '/'
        window.location.href = featureEnabled ? '/spotify/yam' : '/';
    }, 60000); // 60000 milliseconds equals 1 minute
};
