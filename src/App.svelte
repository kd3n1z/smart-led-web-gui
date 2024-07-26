<script lang="ts">
    import { onMount } from 'svelte';
    import spinner from './assets/spinner-solid.svg';

    const apiBase = import.meta.env.DEV ? 'http://192.168.0.110/api?' : window.location.origin + '/api?';
    const apiDelay = 30;

    let color: string;
    let brightness: string;
    let visiblePage = 'loader';

    onMount(async () => {
        const response: string[] = await apiRequest('get-solid-color;get-brightness');

        const rgb = response[0].split(' ').map((e) => parseInt(e));

        color = rgbToHex(rgb[0], rgb[1], rgb[2]);

        brightness = response[1];

        visiblePage = 'main';
    });

    function onChangeColor(value: string) {
        color = value;

        // on some browsers, the change event is called when a change occurs, not when the change is finished
        // set a small delay and check if the color has changed to avoid overloading the API

        setTimeout(() => {
            if (color != value) {
                return;
            }

            const rgb = hexToRgb(value);

            if (rgb != null) {
                apiRequest(`set-solid-color ${rgb.r} ${rgb.g} ${rgb.b}`);
            }
        }, apiDelay);
    }

    function hexToRgb(hex: string) {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result
            ? {
                  r: parseInt(result[1], 16),
                  g: parseInt(result[2], 16),
                  b: parseInt(result[3], 16),
              }
            : null;
    }

    async function apiRequest(...commandsArray: string[]): Promise<string[]> {
        const commands = commandsArray.join(';');

        console.log('making api request: ' + commands);

        const response = (await (await fetch(apiBase + new URLSearchParams({ commands }))).text()).split(';');

        console.log(response);

        return response;
    }

    function componentToHex(c: number) {
        var hex = c.toString(16);
        return hex.length == 1 ? '0' + hex : hex;
    }

    function rgbToHex(r: number, g: number, b: number) {
        return '#' + componentToHex(r) + componentToHex(g) + componentToHex(b);
    }

    function onChangeBrightness(value: string) {
        brightness = value;

        // on some browsers, the change event is called when a change occurs, not when the change is finished
        // set a small delay and check if the color has changed to avoid overloading the API

        setTimeout(() => {
            if (brightness != value) {
                return;
            }

            apiRequest(`set-brightness ${brightness}`);
        }, apiDelay);
    }
</script>

<main>
    <div class={visiblePage == 'loader' ? 'visible' : ''} id="loader">
        <img src={spinner} alt="spinner" />
        Loading...
    </div>
    <div class={visiblePage == 'main' ? 'visible' : ''} id="main">
        <span class="title">Smart LED Web GUI</span>
        <div class="brightness">
            Color
            <input type="color" on:change={(e) => onChangeColor(e.currentTarget.value)} value={color} />
        </div>
        <div class="brightness">
            Brightness
            <input
                type="range"
                on:change={(e) => onChangeBrightness(e.currentTarget.value)}
                min="0"
                max="255"
                value={brightness}
            />
        </div>
    </div>
</main>
