document.addEventListener("DOMContentLoaded", function () {
    let lastPlayingStatus = null;
    let isRequestInProgress = false;

    async function fetchPlayingStatus() {
        if (isRequestInProgress) {
            return null;
        }

        isRequestInProgress = true;

        try {
            const response = await fetch('/playing_status');
            if (!response.ok) throw new Error('Network response was not ok');
            const data = await response.json();
            return data.playing;
        } catch (error) {
            console.error('Error fetching playing status:', error);
            return null;
        } finally {
            isRequestInProgress = false;
        }
    }

    async function fetchAndReplaceContent() {
        if (isRequestInProgress) {
            return;
        }

        const currentPlayingStatus = await fetchPlayingStatus();

        if (currentPlayingStatus !== lastPlayingStatus) {
            lastPlayingStatus = currentPlayingStatus;
            isRequestInProgress = true;

            try {
                const response = await fetch('/content');
                if (!response.ok) throw new Error('Network response was not ok');
                const newContent = await response.text();

                const contentWrapper = document.getElementById('content-wrapper');
                if (!contentWrapper) {
                    console.error('content-wrapper div not found');
                    return;
                }

                const tempDiv = document.createElement('div');
                tempDiv.style.opacity = 0;
                tempDiv.innerHTML = newContent;

                contentWrapper.innerHTML = '';
                contentWrapper.appendChild(tempDiv);

                const scriptToLoad = tempDiv.querySelector('[data-script]');

                if (scriptToLoad) {
                    const scriptId = scriptToLoad.dataset.scriptId;
                    const scriptPath = scriptToLoad.dataset.script;

                    if (window.currentlyLoadedScript) {
                        ScriptManager.unloadScript(window.currentlyLoadedScript);
                    }

                    ScriptManager.loadScript(scriptId, scriptPath);
                    window.currentlyLoadedScript = scriptId;
                }

                tempDiv.style.transition = 'opacity 1s ease';
                requestAnimationFrame(() => {
                    tempDiv.style.opacity = 1;
                });

            } catch (error) {
                console.error('Error fetching new content:', error);
            } finally {
                isRequestInProgress = false;
            }
        }
    }


    fetchAndReplaceContent();
    setInterval(fetchAndReplaceContent, 2000);
});
