// Example: fetch GeoJSON from remote URL
import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, GeoJSON, Circle, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

// Helper to calculate centroid using all points
function getCentroid(geometry) {
    let points = [];
    if (geometry.type === 'Polygon') {
        points = geometry.coordinates[0];
    } else if (geometry.type === 'MultiPolygon') {
        geometry.coordinates.forEach(polygon => {
            // Each polygon[0] should be an array of [lng, lat] pairs
            polygon[0].forEach(point => {
                if (point.length === 2) points.push(point);
            });
        });
    }
    if (!points.length) return null;
    let latSum = 0, lngSum = 0, count = 0;
    points.forEach(([lng, lat]) => {
        latSum += lat;
        lngSum += lng;
        count++;
    });
    return count ? [latSum / count, lngSum / count] : null;
}

function getRandomColor() {
    return '#' + Math.floor(Math.random() * 16777215).toString(16);
}

function Map() {
    const [geoJson, setGeoJson] = useState(null);

    useEffect(() => {
        fetch('/afghanistan-provinces.geojson')
            .then(res => res.json())
            .then(data => setGeoJson(data));
    }, []);

    return (
        <MapContainer center={[34.5, 66.5]} zoom={6} style={{ height: '500px', width: '100%' }}>
            <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution="&copy; OpenStreetMap contributors"
            />
            {geoJson && (
                <>
                    <GeoJSON
                        data={geoJson}
                        style={() => ({
                            color: "#888",
                            weight: 0.5,
                            fillOpacity: 0.02
                        })}
                    />
                    {geoJson.features.map((feature, idx) => {
                        // Skip empty geometries
                        if (!feature.geometry || !feature.geometry.coordinates.length) return null;
                        // Use all points for centroid
                        const center = getCentroid(feature.geometry);
                        if (!center) return null;
                        const color = getRandomColor();
                        const provinceName = feature.properties?.NAME_1 || "Unknown";
                        return (
                            <Circle
                                key={idx}
                                center={center}
                                radius={8000} // Small circle
                                color={color}
                                fillColor={color}
                                fillOpacity={0.2}
                                weight={0.2}
                            >
                                <Popup>
                                    {provinceName}
                                </Popup>
                            </Circle>
                        );
                    })}
                </>
            )}
        </MapContainer>
    );
}

export default Map;