(function(global) {
    const ScriptModule = {
        initialize: function() {
            const reloadAfterDuration = (duration) => {
                setTimeout(() => this.fadeOutAndReload(), duration);
            };

            const fadeOutAndReload = () => {
                const contentWrapper = document.getElementById('content-wrapper');
                if (contentWrapper) {
                    contentWrapper.style.transition = 'opacity 1s ease-out';
                    contentWrapper.style.opacity = '0';

                    new Promise((resolve) => setTimeout(resolve, 1000))
                        .then(() => window.location.reload());
                } else {
                    window.location.reload();
                }
            };

            const artworkCanvas = document.getElementById('artwork_canvas');
            const reloadAfterMs = artworkCanvas ? parseInt(artworkCanvas.dataset.reloadAfterMs, 10) : 5000;

            reloadAfterDuration(reloadAfterMs);
        },
        fadeOutAndReload: function() {
            const contentWrapper = document.getElementById('content-wrapper');
            if (contentWrapper) {
                contentWrapper.style.transition = 'opacity 1s ease-out';
                contentWrapper.style.opacity = '0';

                new Promise((resolve) => setTimeout(resolve, 1000))
                    .then(() => window.location.reload());
            } else {
                window.location.reload();
            }
        }
    };

    // Expose the module to the global scope
    global.ScriptModule = ScriptModule;

    // Immediate initialization removed to allow ScriptManager to control the process

}(window));
