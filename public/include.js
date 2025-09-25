async function includeHTML(id, file) {
    const el = document.getElementById(id);
    if (el) {
        const resp = await fetch(file);
        if (resp.ok) {
            el.innerHTML = await resp.text();
        } else {
            el.innerHTML = "<p>Failed to load " + file + "</p>";
        }
    }
}