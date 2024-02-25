// Function to create and fade in new content (image or video)
const createAndFadeInContent = (data, spotifyCanvas) => {
  const newContent = document.createElement(data.canvas_url ? 'video' : 'img');
  
  const attributes = data.canvas_url ? 
    {src: data.canvas_url, autoplay: true, loop: true, muted: true, playsinline: true, alt: "Canvas Video"} : 
    {src: data.cover_image_url, alt: "Cover Image"};
  
  Object.assign(newContent, attributes);

  // Preload content before adding to DOM and fading in
  if (newContent.tagName === 'IMG') {
    newContent.onload = () => {
      spotifyCanvas.innerHTML = '';
      spotifyCanvas.appendChild(newContent);
      requestAnimationFrame(() => { spotifyCanvas.style.opacity = '1'; });
    };
  } else { // Assume video
    newContent.onloadeddata = () => {
      spotifyCanvas.innerHTML = '';
      spotifyCanvas.appendChild(newContent);
      requestAnimationFrame(() => { spotifyCanvas.style.opacity = '1'; });
    };
  }

  // For immediate content swap without preload, comment out onload/onloadeddata and uncomment below lines:
  // spotifyCanvas.innerHTML = '';
  // spotifyCanvas.appendChild(newContent);
  // requestAnimationFrame(() => { spotifyCanvas.style.opacity = '1'; });
};

document.addEventListener('DOMContentLoaded', function() {
  const updateTrackInfo = () => {
    fetch('/spotify_canvas/current_track')
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
      })
      .then(data => {
        const spotifyCanvas = document.getElementById('spotify_canvas');

        // Fade out current content
        spotifyCanvas.style.opacity = '0';

        setTimeout(() => {
          createAndFadeInContent(data, spotifyCanvas);
        }, 500); // Wait for fade out before adding new content
      })
      .catch(error => {
        console.error('Error fetching current track:', error);
      });
  };

  setInterval(updateTrackInfo, 5000);
});
