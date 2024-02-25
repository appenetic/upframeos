document.addEventListener('DOMContentLoaded', function() {
  const updateTrackInfo = () => {
    fetch('/spotify_canvas/current_track') // Adjust the URL to match your routing setup
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
      })
      .then(data => {
        // Fade out current info and canvas
        const artistInfo = document.getElementsByClassName('track-info');
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

          // Optionally, update the background color if you extract it in your AJAX response
          // document.body.style.backgroundColor = data.background_color;
        }, 500); // Match the CSS transition time
      })
      .catch(error => {
        console.error('Error fetching current track:', error);
      });
  };

  // Update track info every 5 seconds
  setInterval(updateTrackInfo, 5000);
});
