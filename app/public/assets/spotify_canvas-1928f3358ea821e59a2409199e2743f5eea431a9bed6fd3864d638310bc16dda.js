document.addEventListener('DOMContentLoaded', function() {
  let lastTrackId = null; // Variable to store the last track ID

  const updateTrackInfo = () => {
    fetch('/spotify_canvas/current_track') // Adjust the URL to match your routing setup
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
      })
      .then(data => {
        const currentTrackId = `${data.artist_name}-${data.track_name}`; // Example ID generation

        // Check if the track has actually changed
        if (currentTrackId === lastTrackId) {
          // Track has not changed, no need to update the page
          return;
        }

        // Track has changed, update lastTrackId and proceed with updates
        lastTrackId = currentTrackId;

        // Fade out current info and canvas
        const artistInfo = document.getElementById('artist-info');
        const spotifyCanvas = document.getElementById('spotify_canvas');
        artistInfo.style.opacity = '0';
        spotifyCanvas.style.opacity = '0';

        // Wait for fade out to complete
        setTimeout(() => {
          // Update the DOM elements with the new data
          document.getElementById('artist-name').textContent = `${data.artist_name} - ${data.album_name}`;
          document.getElementById('track-name').textContent = data.track_name;
          
          // Update Spotify canvas
          spotifyCanvas.innerHTML = ''; // Clear the current content
          if (data.canvas_url) {
            const video = document.createElement('video');
            Object.assign(video, {src: data.canvas_url, autoplay: true, loop: true, muted: true, playsinline: true, alt: "Canvas Video"});
            spotifyCanvas.appendChild(video);
          } else if (data.cover_image_url) {
            const img = document.createElement('img');
            img.src = data.cover_image_url;
            img.alt = "Cover Image";
            spotifyCanvas.appendChild(img);
          } else {
            spotifyCanvas.textContent = 'No media available.';
          }

          // Fade in updated info and canvas
          artistInfo.style.opacity = '1';
          spotifyCanvas.style.opacity = '1';

          // Update background color if available
          if (data.background_color) {
            document.body.style.backgroundColor = data.background_color;
            console.info('Updated background color');
          }
        }, 500); // Match the CSS transition time
      })
      .catch(error => {
        console.error('Error fetching current track:', error);
      });
  };

  // Update track info every 5 seconds
  setInterval(updateTrackInfo, 5000);
});
