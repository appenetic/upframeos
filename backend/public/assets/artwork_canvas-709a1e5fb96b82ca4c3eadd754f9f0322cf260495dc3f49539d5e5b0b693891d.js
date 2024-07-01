(function(global) {
    const ArtworkScriptModule = {
        currentContent: '',
        updateContentTimeoutId: null,
        updateInProgress: false,
        isLoaded: false,

        initialize: function() {
            console.log('✅ Artwork canvas module loaded')
            this.isLoaded = true
            this.scheduleContentUpdate();
        },

        unload: function () {
            if (this.updateContentTimeoutId) {
                clearTimeout(this.updateContentTimeoutId);
                this.updateContentTimeoutId = null;
            }
            console.log('☑️ Artwork canvas module unloaded.');
            this.isLoaded = false
        },

        scheduleContentUpdate: function() {
            if (!this.isLoaded) return;

            const reloadAfterMs = document.getElementById('artwork_canvas') ? parseInt(document.getElementById('artwork_canvas').dataset.reloadAfterMs, 10) : 5000;
            if (!this.updateInProgress) {
                this.updateContentTimeoutId = setTimeout(() => this.updateContent(), reloadAfterMs);
            }
        },

        updateContent: async function() {
            if (!this.isLoaded || this.isUpdatingContent) {
                console.log('Update already in progress. Skipping...');
                return;
            }

            this.updateInProgress = true;
            console.log('Updating content now.');

            try {
                const response = await fetch('/content');
                if (!response.ok) throw new Error('Network response was not ok');

                const contentType = response.headers.get("content-type");

                if (contentType && contentType.includes("video")) {
                    // Assuming that the video content is a direct URL to the video file
                    const videoBlob = await response.blob();
                    const videoURL = URL.createObjectURL(videoBlob);
                    this.loadVideo(videoURL);
                } else {
                    const newContent = await response.text();
                    this.updateHTMLContent(newContent);
                }
            } catch (error) {
                console.error('Error fetching new content:', error);
            } finally {
                this.updateInProgress = false;
                this.scheduleContentUpdate();
            }
        },

        currentVideoBlobUrl: '',

        loadVideo: function(videoURL) {
            const artworkCanvas = document.getElementById('artwork_canvas');
            if (artworkCanvas) {
                // Check if the video URL has changed
                if (this.currentVideoBlobUrl !== videoURL) {
                    // Clean up the previous video if there was one
                    if (this.currentVideoBlobUrl) {
                        URL.revokeObjectURL(this.currentVideoBlobUrl);
                    }

                    // Update the current video Blob URL
                    this.currentVideoBlobUrl = videoURL;

                    // Create a new video element
                    const videoElement = document.createElement('video');
                    videoElement.classList.add('artwork-video');
                    videoElement.setAttribute('autoplay', true);
                    videoElement.setAttribute('loop', true);
                    videoElement.setAttribute('muted', true);
                    videoElement.setAttribute('playsinline', true);
                    videoElement.innerHTML = `<source src="${this.currentVideoBlobUrl}" type="video/mp4">`;

                    artworkCanvas.innerHTML = '';
                    artworkCanvas.appendChild(videoElement);
                }
            }
        },
        updateHTMLContent: function(newContent) {
            if (newContent.trim() !== this.currentContent.trim()) {
                this.currentContent = newContent.trim();
                const artworkCanvas = document.getElementById('artwork_canvas');
                if (artworkCanvas) {
                    artworkCanvas.innerHTML = '';
                    const newContentContainer = document.createElement('div');
                    newContentContainer.style.opacity = '0';
                    newContentContainer.innerHTML = newContent;
                    artworkCanvas.appendChild(newContentContainer);

                    setTimeout(() => {
                        newContentContainer.style.transition = 'opacity 1s ease';
                        newContentContainer.style.opacity = '1';
                    }, 100);
                }
            } else {
                console.log('Content has not changed, no update needed.');
            }
        }
    };

    global.ScriptModule = ArtworkScriptModule;
}(window));
