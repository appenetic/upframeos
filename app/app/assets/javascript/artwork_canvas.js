if (document.readyState === "loading") {
    document.addEventListener('DOMContentLoaded', initialize);
} else {
    initialize();
}

function initialize() {
    // Define a function to reload the page after a specified duration
    function reloadAfterDuration(duration) {
        setTimeout(function() {
            fadeOutAndReload();
        }, duration);
    }

    // Function to fade out the content and then reload the page
    function fadeOutAndReload() {
        // Assuming there's a main content wrapper you can fade out
        var contentWrapper = document.getElementById('content-wrapper');
        if (contentWrapper) {
            // Fade out the content
            contentWrapper.style.transition = 'opacity 1s ease-out';
            contentWrapper.style.opacity = 0;

            // Set a timeout to match the fade duration, then reload
            setTimeout(function() {
                location.reload();
            }, 1000); // Match this duration to your fade effect duration
        } else {
            // If no contentWrapper found, just reload
            location.reload();
        }
    }

    // Get the reload duration from the data attribute
    var artworkCanvas = document.getElementById('artwork_canvas');
    var reloadAfterMs = artworkCanvas ? artworkCanvas.dataset.reloadAfterMs : 5000; // Fallback duration

    // Call the function with the reload duration
    reloadAfterDuration(reloadAfterMs);
}
