function includeHTML(id, file, callback) {
    const el = document.getElementById(id);
    if (el) {
        fetch(file)
            .then(response => {
                if (!response.ok) throw new Error('Network error');
                return response.text();
            })
            .then(html => {
                el.innerHTML = html;
                if (typeof callback === 'function') callback(); // run callback
            })
            .catch(err => {
                console.error('Error including HTML:', err);
                el.innerHTML = "<p>Failed to load content.</p>";
            });
    }
}
