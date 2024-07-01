(function(global) {
    const ArtworkScriptModule = {
        currentContent: '',
        updateContentTimeoutId: null,
        updateInProgress: false,
        isLoaded: false,
        videoBlobUrl: null, // Store the blob URL for the video

        initialize: function() {
            console.log('✅ Artwork canvas module loaded');
            this.isLoaded = true;
            this.updateContent(true); // Immediately attempt to update content on initialization
        },

        unload: function () {
            if (this.updateContentTimeoutId) {
                clearTimeout(this.updateContentTimeoutId);
                this.updateContentTimeoutId = null;
            }
            if (this.videoBlobUrl) {
                URL.revokeObjectURL(this.videoBlobUrl); // Clean up the blob URL
                this.videoBlobUrl = null;
            }
            console.log('☑️ Artwork canvas module unloaded.');
            this.isLoaded = false;
        },

        scheduleContentUpdate: function() {
            if (!this.isLoaded) return;

            const reloadAfterMs = 10
            console.log(`Updating content after: ${reloadAfterMs}`)
            console.log(`Update in progress: ${this.updateInProgress}`)

            if (!this.updateInProgress) {
                this.updateContentTimeoutId = setTimeout(() => this.updateContent(), reloadAfterMs);
            }
        },

        updateContent: async function(initial = false) {
            if (!this.isLoaded || (this.updateInProgress && !initial)) {
                console.log('Update already in progress. Skipping...');
                return;
            }

            this.updateInProgress = true;
            console.log('Updating content now.');

            try {
                const response = await fetch('/artwork_data');
                if (!response.ok) throw new Error('Network response was not ok');
                const jsonResponse = await response.json(); // Parse the JSON response

                // Directly use jsonResponse to check for updates and handle video URL
                const assetUrl = jsonResponse.asset_url;
                const isVideo = jsonResponse.is_video || false;
                const fillMode = jsonResponse.fill_mode

                if (assetUrl && (assetUrl !== this.currentContent || initial)) {
                    this.currentContent = assetUrl;
                    this.processNewContent(assetUrl, isVideo, fillMode); // Process new content with the asset URL and its type
                } else {
                    console.log('Content has not changed, no update needed.');
                }
            } catch (error) {
                console.error('Error fetching new content:', error);
            } finally {
                console.log("Executing finally block")
                this.updateInProgress = false;
                if (!initial) {
                    console.log("Schedulung content update")
                    this.scheduleContentUpdate();
                }
            }
        },

        processNewContent: function(assetUrl, isVideo, fillMode) {
            const artworkCanvas = document.getElementById('artwork_canvas');
            artworkCanvas.innerHTML = ''; // Clear existing content

            if (isVideo) {
                this.createVideoTag(assetUrl, fillMode);
            } else {
                this.createImageTag(assetUrl, fillMode);
            }
        },

        createVideoTag: function(assetUrl, fillMode) {
            const videoElement = document.createElement('video');
            videoElement.className = 'artwork-video';
            videoElement.autoplay = true;
            videoElement.loop = true;
            videoElement.muted = true;
            videoElement.playsinline = true;
            videoElement.src = assetUrl;

            let objectFitValue;
            if (fillMode === 'fit_screen') {
                objectFitValue = 'contain';
            } else if (fillMode === 'fill_screen') {
                objectFitValue = 'cover';
            }

            if (objectFitValue) {
                videoElement.style.objectFit = objectFitValue;
            }

            const artworkCanvas = document.getElementById('artwork_canvas');
            artworkCanvas.appendChild(videoElement);
        },

        createImageTag: function(assetUrl, fillMode) {
            const imageElement = document.createElement('img');
            imageElement.className = 'artwork-image';
            imageElement.src = assetUrl;
            imageElement.alt = 'Artwork Image';

            if (fillMode) {
                let objectFitValue;
                if (fillMode === 'fit_screen') {
                    objectFitValue = 'contain';
                } else if (fillMode === 'fill_screen') {
                    objectFitValue = 'cover';
                }
                imageElement.style.objectFit = objectFitValue;
            }

            const artworkCanvas = document.getElementById('artwork_canvas');
            artworkCanvas.appendChild(imageElement);
        },
    };

    global.ScriptModule = ArtworkScriptModule;
}(window));
