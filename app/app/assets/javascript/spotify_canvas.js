document.addEventListener('DOMContentLoaded', function() {
    let lastTrackId = null;

    const fadeElement = (element, fadeIn, callback) => {
        // Initial setup for fade-out
        if (!fadeIn) {
            element.style.opacity = '0';
        }

        // Wait for the transition to complete
        element.addEventListener('transitionend', function handler() {
            element.removeEventListener('transitionend', handler);

            // Perform the callback function between fade-out and fade-in
            if (typeof callback === 'function') {
                callback();
            }

            // Setup for fade-in
            if (fadeIn) {
                element.style.opacity = '1';
            }
        }, { once: true });

        // If fading in, immediately start after setting up the listener
        if (fadeIn) {
            // Use a slight delay to ensure the listener is active before changing opacity
            setTimeout(() => element.style.opacity = '1', 10);
        }
    };

    const updateContentAndFadeIn = (data) => {
        // Update the DOM elements with the new data
        document.getElementById('artist-name').textContent = `${data.artist_name} - ${data.album_name}`;
        document.getElementById('track-name').textContent = data.track_name;

        const spotifyCanvas = document.getElementById('spotify_canvas');
        spotifyCanvas.innerHTML = ''; // Clear the current content

        if (data.canvas_url) {
            const video = document.createElement('video');
            Object.assign(video, { src: data.canvas_url, autoplay: true, loop: true, muted: true, playsinline: true, alt: "Canvas Video" });
            spotifyCanvas.appendChild(video);
        } else if (data.cover_image_url) {
            const img = document.createElement('img');
            img.src = data.cover_image_url;
            img.alt = "Cover Image";
            spotifyCanvas.appendChild(img);
        } else {
            spotifyCanvas.textContent = 'No media available.';
        }

        // Fade in the updated info and canvas
        const artistInfo = document.getElementById('artist-info');
        fadeElement(artistInfo, true);
        fadeElement(spotifyCanvas, true);
    };

    const updateTrackInfo = () => {
        fetch('/current_track')
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok');
                return response.json();
            })
            .then(data => {
                const currentTrackId = `${data.artist_name}-${data.track_name}`;

                if (currentTrackId === lastTrackId) {
                    return; // Track has not changed, no need to update the page
                }
                lastTrackId = currentTrackId;

                // Fade out current info and canvas before updating
                const artistInfo = document.getElementById('artist-info');
                const spotifyCanvas = document.getElementById('spotify_canvas');

                fadeElement(artistInfo, false, () => updateContentAndFadeIn(data));
                fadeElement(spotifyCanvas, false);

                // Update background color if available, no fade effect required here
                if (data.background_color) {
                    document.body.style.backgroundColor = data.background_color;
                }
            })
            .catch(error => {
                console.error('Error fetching current track:', error);
            });
    };

    // Update track info every 5 seconds
    setInterval(updateTrackInfo, 5000);
});
