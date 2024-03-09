(function(global) {
    const SpotifyScriptModule = {
        updateTrackInfoIntervalId: null,

        initialize: function() {
            console.log('✅ Spotify module loaded');

            const ensureElement = (id, type, parent) => {
                let element = document.getElementById(id);
                if (!element) {
                    element = document.createElement(type);
                    element.id = id;
                    parent.appendChild(element);
                }
                return element;
            };

            const fadeElement = (element, fadeIn = true) => {
                return new Promise(resolve => {
                    element.style.transition = 'opacity 0.5s';
                    element.style.opacity = fadeIn ? '1' : '0';
                    const transitionEnd = () => {
                        element.removeEventListener('transitionend', transitionEnd);
                        resolve();
                    };
                    element.addEventListener('transitionend', transitionEnd, { once: true });
                });
            };

            const updateMediaElement = (container, data) => {
                container.innerHTML = '';
                let element;
                if (data.canvas_url) {
                    element = document.createElement('video');
                    Object.assign(element, {
                        src: data.canvas_url,
                        autoplay: true,
                        loop: true,
                        muted: true,
                        playsinline: true
                    });
                } else if (data.cover_image_url) {
                    element = document.createElement('img');
                    Object.assign(element, { src: data.cover_image_url });
                } else {
                    container.textContent = 'No media available.';
                    return;
                }
                element.alt = data.canvas_url ? "Canvas Video" : "Cover Image";
                container.appendChild(element);
            };

            const updateBackgroundColor = (color) => {
                if (color && document.body.style.backgroundColor !== color) {
                    document.body.style.backgroundColor = color;
                }
            };

            const updateContentAndFadeIn = async (data) => {
                const artistInfo = document.getElementById('artist-info');
                const spotifyCanvas = document.getElementById('spotify_canvas');
                await fadeElement(artistInfo, false);
                await fadeElement(spotifyCanvas, false);

                document.getElementById('artist-name').textContent = `${data.artist_name} - ${data.album_name}`;
                document.getElementById('track-name').textContent = data.track_name;

                updateMediaElement(spotifyCanvas, data);

                await fadeElement(artistInfo, true);
                await fadeElement(spotifyCanvas, true);

                updateBackgroundColor(data.background_color);
            };

            let lastTrackId = null;

            const updateTrackInfo = async () => {
                try {
                    const response = await fetch('/current_track');
                    if (!response.ok) throw new Error('Network response was not ok');
                    const data = await response.json();
                    const currentTrackId = `${data.artist_name}-${data.track_name}`;

                    if (currentTrackId !== lastTrackId) {
                        lastTrackId = currentTrackId;
                        await updateContentAndFadeIn(data);
                    }
                } catch (error) {

                }
            };

            this.updateTrackInfoIntervalId = setInterval(updateTrackInfo, 5000);
        },

        unload: function() {
            if (this.updateTrackInfoIntervalId) {
                clearInterval(this.updateTrackInfoIntervalId);
                this.updateTrackInfoIntervalId = null;
            }
            console.log('☑️ Spotify module unloaded.');
        },
    };

    global.ScriptModule = SpotifyScriptModule;
})(window);