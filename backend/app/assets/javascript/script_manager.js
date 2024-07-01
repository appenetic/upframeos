const ScriptManager = {
    loadScript: function(scriptId, scriptPath) {
        this.unloadScript(scriptId);
        if (!document.getElementById(scriptId)) {
            const script = document.createElement('script');
            script.id = scriptId;
            script.src = scriptPath;
            script.onload = () => {
                console.log(`➕ ${scriptId} loaded.`);
                if (window.ScriptModule) {
                    window.ScriptModule.initialize();
                    window.myScriptUnload = window.ScriptModule.unload.bind(window.ScriptModule); // Assign the unload function
                }
            };
            document.head.appendChild(script);
        }
    },
    unloadScript: function(scriptId) {
        const scriptElement = document.getElementById(scriptId);
        if (scriptElement) {
            console.log(`➖ ${scriptId} unloading.`);

            document.head.removeChild(scriptElement);

            if (typeof window.myScriptUnload === 'function') {
                window.myScriptUnload();
            }
        }
    }
};