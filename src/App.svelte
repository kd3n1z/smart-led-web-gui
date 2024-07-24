<script lang="ts">
    function onChangeColor(color: string) {
        const rgb = hexToRgb(color);

        if (rgb != null) {
            apiRequest(`set-solid-color ${rgb.r} ${rgb.g} ${rgb.b}`);
        }
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

    function apiRequest(...commandsArray: string[]) {
        const commands = commandsArray.join(';');

        console.log('making api request: ' + commands);

        fetch(window.location.origin + '/api?' + new URLSearchParams({ commands }));
    }
</script>

<main>
    Smart LED Web GUI

    <div>
        <input type="color" on:change={(e) => onChangeColor(e.currentTarget.value)} />
    </div>
</main>
