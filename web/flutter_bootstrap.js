{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    await new Promise((resolve) => setTimeout(resolve, 800));
    window.removeSplashFromWeb();
  },
});
