document.addEventListener('DOMContentLoaded', function() {
    if (!document.body.classList.contains('map-page')) {
        return;
    }

    // Check if Leaflet is loaded
    if (typeof L === 'undefined') {
        console.error('Leaflet is not loaded. Please check that the Leaflet script is included.');
        return;
    }

    let currentMap = null;
    let currentView = { center: [0, 0], zoom: 2 };

    const mapConfigs = {
        'triune-duchy': {
            center: [0, 0],
            zoom: 2,
            name: 'The Triune Duchy'
        },
        'pale-vein': {
            center: [0, 0],
            zoom: 2,
            name: 'The Pale Vein'
        }
    };

    function initMap(mapType) {
        const config = mapConfigs[mapType];
        if (!config) {
            console.error('Unknown map type:', mapType);
            return;
        }

        if (currentMap) {
            currentMap.remove();
        }

        currentMap = L.map('map-container').setView(currentView.center, currentView.zoom);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            maxZoom: 18
        }).addTo(currentMap);

        currentMap.on('moveend zoomend', function() {
            currentView.center = currentMap.getCenter();
            currentView.zoom = currentMap.getZoom();
        });

        console.log(`Initialized map: ${config.name} at ${currentView.center}, zoom ${currentView.zoom}`);
    }

    function switchMap(mapType) {
        initMap(mapType);

        document.querySelectorAll('.map-switch-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-map="${mapType}"]`).classList.add('active');
    }

    document.querySelectorAll('.map-switch-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const mapType = this.getAttribute('data-map');
            switchMap(mapType);
        });
    });

    const firstMapType = 'triune-duchy';
    initMap(firstMapType);
    
    document.querySelector(`[data-map="${firstMapType}"]`).classList.add('active');
});