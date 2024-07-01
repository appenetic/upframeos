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
            if (!this.isLoaded || this.updateInProgress && !initial) {
                console.log('Update already in progress. Skipping...');
                return;
            }

            this.updateInProgress = true;
            console.log('Updating content now.');

            try {
                const response = await fetch('/artwork_data');
                if (!response.ok) throw new Error('Network response was not ok');
                const newContent = await response.text();

                // Assuming your content includes specific markers or URLs for images or videos
                // This is where you'd inspect `newContent` and decide how to handle it.
                // For a video, you'd fetch it, create a blob URL, and then set it as the src for your video tag.

                console.log(`Got content: ${newContent}`)

                if (newContent.trim() !== this.currentContent.trim() || initial) {
                    this.currentContent = newContent.trim();
                    // Handle the content update, including video processing
                    this.processNewContent(newContent);
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

        processNewContent: function(content) {
            const artworkCanvas = document.getElementById('artwork_canvas');
            if (artworkCanvas) {
                artworkCanvas.innerHTML = ''; // Clear existing content
                const newContentContainer = document.createElement('div');
                newContentContainer.style.opacity = '0';
                newContentContainer.innerHTML = content;
                artworkCanvas.appendChild(newContentContainer);

                // Check if a video URL is present in the new content and fetch it
                const videoUrlMatch = content.match(/src="([^"]+)"/); // Simple regex to find video src
                if (videoUrlMatch && videoUrlMatch[1]) {
                    this.fetchAndSetVideo(videoUrlMatch[1]);
                }

                setTimeout(() => {
                    newContentContainer.style.transition = 'opacity 1s ease';
                    newContentContainer.style.opacity = '1';
                }, 100);
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
        }
    };

    global.ScriptModule = ArtworkScriptModule;
}(window));
