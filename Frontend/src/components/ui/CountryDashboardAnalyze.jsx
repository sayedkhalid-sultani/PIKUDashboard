import React, { useState, useEffect } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

// Only two colors for circle groups
const groupColors = ["#3b82f6", "#f59e42"];

const getRandomSize = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

// Predefined center points for Afghanistan provinces
const provinceCenters = {
    "Badakhshan": [36.7348, 70.8120],
    "Badghis": [35.1670, 63.7690],
    "Baghlan": [35.8000, 68.9000],
    "Balkh": [36.7550, 66.8970],
    "Bamyan": [34.7000, 67.1333],
    "Daykundi": [33.7500, 66.2500],
    "Farah": [32.3750, 62.1167],
    "Faryab": [36.1500, 64.8333],
    "Ghazni": [33.5500, 67.9000],
    "Ghor": [34.5167, 65.2500],
    "Helmand": [31.5833, 64.3667],
    "Herat": [34.3419, 62.2031],
    "Jowzjan": [36.7500, 65.8333],
    "Kabul": [34.5167, 69.1833],
    "Kandahar": [31.6167, 65.7167],
    "Kapisa": [34.8833, 69.6833],
    "Khost": [33.3500, 69.9167],
    "Kunar": [35.0000, 71.2167],
    "Kunduz": [36.7333, 68.8667],
    "Laghman": [34.6667, 70.2167],
    "Logar": [34.0000, 69.2333],
    "Nangarhar": [34.25, 70.4500],
    "Nimruz": [31.0500, 62.4500],
    "Nuristan": [35.2500, 70.7500],
    "Paktia": [33.6000, 69.5000],
    "Paktika": [32.5000, 68.7667],
    "Panjshir": [35.32000, 69.7200],
    "Parwan": [35.0000, 69.0000],
    "Samangan": [36.0000, 67.8333],
    "SariPul": [35.6000, 66.0000],
    "Takhar": [36.7333, 69.5333],
    "Urozgan": [32.9333, 66.6333],
    "Wardak": [34.4000, 68.4500],
    "Zabul": [32.4000, 67.0000]
};

const provinceStyle = {
    fillColor: '#fbbf24',
    weight: 2,
    opacity: 1,
    color: '#6366f1',
    dashArray: '3',
    fillOpacity: 0.5
};

function CountryDashboardAnalyze() {
    const [geoData, setGeoData] = useState(null);
    const [circleGroups, setCircleGroups] = useState([]);

    useEffect(() => {
        fetch('/public/afghanistan-provinces.geojson')
            .then(res => res.json())
            .then(data => {
                setGeoData(data);

                // For each province, create two circles with two colors (alternating)
                const groups = data.features.map((feature) => {
                    const provinceName = feature.properties.NAME_1;
                    let center = provinceCenters[provinceName];
                    if (!center) {
                        const coords = feature.geometry.type === 'Polygon'
                            ? feature.geometry.coordinates[0]
                            : feature.geometry.coordinates[0][0];
                        let sumLat = 0, sumLng = 0, count = 0;
                        for (const coord of coords) {
                            sumLng += coord[0];
                            sumLat += coord[1];
                            count++;
                        }
                        center = [sumLat / count, sumLng / count];
                    }
                    // Offset for second circle (slightly north-east)
                    const offset = [center[0] + 0.15, center[1] + 0.15];
                    return {
                        province: provinceName,
                        circles: [
                            { position: center, radius: getRandomSize(5000, 20000), color: groupColors[0] },
                            { position: offset, radius: getRandomSize(5000, 20000), color: groupColors[1] }
                        ]
                    };
                });

                setCircleGroups(groups);
            });
    }, []);

    return (
        <div className="flex h-full w-full min-h-0">
            {/* Sidebar: 1/4 width on md+, full width on mobile */}
            <div className="w-full md:w-2/7 flex-none min-h-0 flex flex-col gap-6 overflow-y-auto ">
                {/* Sidebar Title and Subtitle as card */}
                <div className="w-full bg-white  px-6 flex flex-col mt-4">
                    <h2 className="text-2xl font-bold text-blue-700">Please select the indicators</h2>
                    <p className="text-gray-500 text-base mt-1">
                        Choose two indicators from the dropdowns below to visualize and compare data for Afghanistan provinces.
                    </p>
                </div>
                {/* Indicator 1 Card */}
                <div className="w-full bg-white  px-6 flex flex-col gap-4">
                    <h3 className="text-lg font-bold text-blue-700 mb-2">Indicator 1</h3>
                    <select
                        className="w-full border border-blue-200 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
                    >
                        <option>Population</option>
                        <option>Male Literacy Rate</option>
                        <option>GDP</option>
                    </select>
                    <label className="text-blue-700 font-semibold ">Value</label>
                    <div className="w-full h-1  rounded bg-gradient-to-r from-blue-500 to-orange-400" />
                    <label className="text-blue-700 font-semibold mb-2">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-4 py-2 min-h-[80px] focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>
                {/* Indicator 2 Card */}
                <div className="w-full bg-white  p-6 flex flex-col gap-4">
                    <h3 className="text-lg font-bold text-orange-500 mb-2">Indicator 2</h3>
                    <select
                        className="w-full border border-orange-200 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-400 transition"
                    >
                        <option>Population</option>
                        <option>Male Literacy Rate</option>
                        <option>GDP</option>
                    </select>
                    <label className="text-orange-500 font-semibold">Value</label>
                    <div className="w-full h-1  rounded bg-gradient-to-r from-orange-400 to-blue-500" />
                    <label className="text-orange-500 font-semibold mb-2">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-4 py-2 min-h-[80px] focus:outline-none focus:ring-2 focus:ring-orange-400 transition"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>
            </div>
            {/* Responsive wrapper for map area */}
            <div className="md:w-5/7 flex-1 min-h-0 h-full">
                <div className="w-full h-full min-h-0 rounded-lg shadow">
                    <MapContainer
                        center={[33.9391, 67.7100]}
                        zoom={6}
                        className="w-full h-full"
                        style={{ width: "100%", height: "100%" }}
                    >
                        <TileLayer
                            attribution='&copy; <a href="https://carto.com/">CartoDB</a> contributors'
                            url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                        />
                        {geoData && (
                            <GeoJSON
                                data={geoData}
                                style={provinceStyle}
                            />
                        )}
                        {circleGroups.length > 0 && (
                            <>
                                {circleGroups.map((group) =>
                                    group.circles.map((circle, cIdx) => (
                                        <Circle
                                            key={`${group.province}-${cIdx}`}
                                            center={circle.position}
                                            radius={circle.radius}
                                            pathOptions={{
                                                color: circle.color,
                                                fillColor: circle.color,
                                                fillOpacity: 0.7,
                                                weight: 2
                                            }}
                                        />
                                    ))
                                )}
                            </>
                        )}
                    </MapContainer>
                </div>
            </div>
        </div>
    );
}

export default CountryDashboardAnalyze;