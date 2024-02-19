document.addEventListener("DOMContentLoaded", function() {
    const body = document.querySelector('body');
    const initialTrackURI = body.dataset.initialTrackUri;
    const reloadAfterMs = parseInt(body.dataset.reloadAfterMs, 10);
  
    document.body.classList.add("fade-in");
  
    function checkCurrentTrack() {
      fetch('/spotify_canvas/current_track')
        .then(response => response.json())
        .then(data => {
          if (data.current_track_uri !== initialTrackURI) {
            reloadWithCrossfade();
          }
        })
        .catch(error => console.error('Error fetching current track:', error));
    }
  
    function reloadWithCrossfade() {
      document.body.classList.add("fade-out");
      setTimeout(function() {
        window.location.reload();
      }, 1000); // Assuming the fade-out takes 1 second
    }
  
    setInterval(checkCurrentTrack, 5000);
    setTimeout(reloadWithCrossfade, reloadAfterMs - 1000);
  });
  
