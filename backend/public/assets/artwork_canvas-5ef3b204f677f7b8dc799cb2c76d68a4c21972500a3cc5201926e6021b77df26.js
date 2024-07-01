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

            const reloadAfterMs = document.getElementById('artwork_canvas') ? parseInt(document.getElementById('artwork_canvas').dataset.reloadAfterMs, 10) : 5000;
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

                console.log(`Got content: ${JSON.stringify(jsonResponse)}`);

                // Directly use jsonResponse to check for updates and handle video URL
                const assetUrl = jsonResponse.asset_url;
                const isVideo = jsonResponse.is_video || false;
                if (assetUrl && (assetUrl !== this.currentContent || initial)) {
                    this.currentContent = assetUrl;
                    this.processNewContent(assetUrl, isVideo); // Process new content with the asset URL and its type
                } else {
                    console.log('Content has not changed, no update needed.');
                }
            } catch (error) {
                console.error('Error fetching new content:', error);
            } finally {
                this.updateInProgress = false;
                if (!initial) {
                    this.scheduleContentUpdate();
                }
            }
        },

        processNewContent: function(assetUrl, isVideo) {
            if (isVideo) {
                console.info("Configuring canvas to display artwork video")
                this.fetchAndSetVideo(assetUrl); // Fetch and set the video using the URL from JSON
            } else {
                console.info("Configuring canvas to display artwork image")
                this.setImage(assetUrl); // Set the image using the URL from JSON
            }
        },

        fetchAndSetVideo: async function(url) {
            try {
                const videoResponse = await fetch(url);
                if (!videoResponse.ok) throw new Error('Video fetch response was not ok');
                const videoBlob = await videoResponse.blob();
                if (this.videoBlobUrl) {
                    URL.revokeObjectURL(this.videoBlobUrl); // Clean up the old blob URL
                }
                this.videoBlobUrl = URL.createObjectURL(videoBlob);
                const videoElement = document.querySelector('.artwork-video');
                if (videoElement) videoElement.src = this.videoBlobUrl;
            } catch (error) {
                console.error('Error fetching video content:', error);
            }
        },

        setImage: function(assetUrl) {
            const imageElement = document.querySelector('.artwork-image');
            if (imageElement) imageElement.src = assetUrl;
        },
    };

    global.ScriptModule = ArtworkScriptModule;
}(window));
