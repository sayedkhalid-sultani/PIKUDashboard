import { useState, useEffect, useRef } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Legend, PieChart, Pie, LineChart, Line, ComposedChart, Cell } from 'recharts';

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const provinceStyle = {
    fillColor: '#fbbf24', // amber-400
    weight: 2,
    opacity: 1,
    color: '#6366f1', // indigo-500 border
    dashArray: '3',
    fillOpacity: 0.5
};

// Use a vibrant color palette for circles
const circleColors = [
    '#ef4444', // red-500
    '#f59e42', // orange-400
    '#22c55e', // green-500
    '#3b82f6', // blue-500
    '#a21caf', // purple-700
    '#eab308', // yellow-500
    '#14b8a6', // teal-500
    '#f43f5e', // pink-500
    '#0ea5e9', // sky-500
    '#6366f1', // indigo-500
];

const getCircleColor = (idx) => circleColors[idx % circleColors.length];

// Function to generate random size between min and max
const getRandomSize = (min, max) => {
    return Math.floor(Math.random() * (max - min + 1)) + min;
};

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

// Component to handle circle layer ordering
const CirclesLayer = ({ circleData, geoData, onCircleClick }) => {
    const map = useMap();

    useEffect(() => {
        // Bring all circles to front after render
        setTimeout(() => {
            Object.values(map._layers).forEach(layer => {
                // Only bring Circle layers to front
                if (layer instanceof L.Circle) {
                    layer.bringToFront();
                }
            });
        }, 200);
    }, [circleData, map]);

    return (
        <>
            {circleData.map((circle, index) => (
                <Circle
                    key={index}
                    center={circle.position}
                    radius={circle.radius}
                    pathOptions={{
                        color: getCircleColor(index),
                        fillColor: getCircleColor(index),
                        fillOpacity: 0.85, // Not transparent
                        weight: 2
                    }}
                    eventHandlers={{
                        click: () => onCircleClick(circle, geoData)
                    }}
                />
            ))}
        </>
    );
};

const getResponsiveZoom = () => {
    if (window.innerWidth < 640) return 5;      // Mobile
    if (window.innerWidth < 1024) return 6;     // Tablet
    return 7;                                   // Desktop
};

const Map = () => {
    const [geoData, setGeoData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [selectedProvince, setSelectedProvince] = useState(null);
    const [circleData, setCircleData] = useState([]);
    const [mapZoom, setMapZoom] = useState(getResponsiveZoom());
    const mapRef = useRef();
    const modalRef = useRef();

    // Update zoom on resize
    useEffect(() => {
        const handleResize = () => setMapZoom(getResponsiveZoom());
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);

    useEffect(() => {
        fetch('/public/afghanistan-provinces.geojson')
            .then(res => res.json())
            .then(data => {
                setGeoData(data);

                // Create circle data for each province
                const circles = data.features.map((feature, idx) => {
                    const provinceName = feature.properties.NAME_1;
                    const center = provinceCenters[provinceName];

                    // If no center found, try to calculate centroid from the feature geometry
                    if (!center) {
                        // console.warn(`No center found for province: ${provinceName}`);
                        // Calculate centroid as fallback
                        const coords = feature.geometry.type === 'Polygon'
                            ? feature.geometry.coordinates[0]
                            : feature.geometry.coordinates[0][0];

                        let sumLat = 0;
                        let sumLng = 0;
                        let count = 0;

                        for (const coord of coords) {
                            sumLng += coord[0];
                            sumLat += coord[1];
                            count++;
                        }

                        const centroid = [sumLat / count, sumLng / count];
                        return {
                            position: centroid,
                            radius: getRandomSize(5000, 20000),
                            province: provinceName,
                            color: getCircleColor(idx)
                        };
                    }

                    return {
                        position: center,
                        radius: getRandomSize(5000, 20000),
                        province: provinceName,
                        color: getCircleColor(idx)
                    };
                });

                setCircleData(circles);
            })
            .catch(error => {
                console.error('Error loading GeoJSON:', error);
                setLoading(false);
            })
            .finally(() => setLoading(false));
    }, []);

    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Escape') setSelectedProvince(null);
        };
        if (selectedProvince) {
            window.addEventListener('keydown', handleKeyDown);
        }
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [selectedProvince]);

    const handleCircleClick = (circle, geoData) => {
        // Find the province feature for this circle
        const provinceFeature = geoData.features.find(
            f => f.properties.NAME_1 === circle.province
        );

        if (provinceFeature) {
            // Create a temporary layer to get bounds
            const tempLayer = L.geoJSON(provinceFeature);
            const bounds = tempLayer.getBounds();

            setSelectedProvince({
                name: circle.province,
                type: provinceFeature.properties.TYPE_1 || provinceFeature.properties.ENGTYPE_1 || 'Province',
                details: provinceFeature.properties.VARNAME_1 || '',
                bounds: bounds
            });

            if (mapRef.current) {
                mapRef.current.fitBounds(bounds, { padding: [40, 40] });
            }
        }
    };

    const onEachProvince = (feature, layer) => {
        layer.on({
            click: () => {
                setSelectedProvince({
                    name: feature.properties.NAME_1,
                    type: feature.properties.TYPE_1 || feature.properties.ENGTYPE_1 || 'Province',
                    details: feature.properties.VARNAME_1 || '',
                    bounds: layer.getBounds()
                });
                if (mapRef.current) {
                    mapRef.current.fitBounds(layer.getBounds(), { padding: [40, 40] });
                }
            },
            mouseover: () => {
                layer.setStyle({
                    weight: 3,
                    color: '#666',
                    dashArray: '',
                    fillOpacity: 0.7
                });
                layer.bringToFront();
            },
            mouseout: () => {
                layer.setStyle(provinceStyle);
            }
        });
        layer.bindTooltip(feature.properties.NAME_1, { direction: 'center' });
    };

    if (loading) {
        return <div className="flex items-center justify-center h-screen text-gray-600">Loading map data...</div>;
    }

    return (
        <div className="relative w-full h-full flex flex-col md:flex-row">
            {/* Map area: responsive width */}
            <div className="relative w-full md:w-2/3 h-[300px] md:h-full overflow-hidden">
                <MapContainer
                    center={[33.9391, 67.7100]}
                    zoom={mapZoom}
                    className="w-full h-full"
                    whenCreated={mapInstance => { mapRef.current = mapInstance; }}
                >
                    <TileLayer
                        attribution='&copy; <a href="https://carto.com/">CartoDB</a> contributors'
                        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                    />
                    {geoData && (
                        <GeoJSON
                            data={geoData}
                            style={provinceStyle}
                            onEachFeature={onEachProvince}
                        />
                    )}
                    {geoData && circleData.length > 0 && (
                        <CirclesLayer
                            circleData={circleData}
                            geoData={geoData}
                            onCircleClick={handleCircleClick}
                        />
                    )}
                </MapContainer>
                {selectedProvince && (
                    <>
                        <div
                            className="absolute inset-0  bg-opacity-20 backdrop-blur-sm z-[1000]"
                            onClick={() => setSelectedProvince(null)}
                        />
                        <div
                            ref={modalRef}
                            className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-white bg-opacity-90 border border-gray-200 shadow-xl rounded-lg p-6 w-full max-w-md z-[1001]"
                            tabIndex={-1}
                            aria-modal="true"
                            role="dialog"
                            onClick={e => e.stopPropagation()}
                        >
                            <button
                                className="absolute top-3 right-3 text-gray-500 hover:text-gray-700 text-xl font-bold"
                                onClick={() => setSelectedProvince(null)}
                                aria-label="Close modal"
                            >
                                &times;
                            </button>
                            <h2 className="text-2xl font-bold text-blue-800 mb-2">{selectedProvince.name}</h2>
                            <p className="text-gray-700 mb-3">Type: {selectedProvince.type}</p>
                            {selectedProvince.details && (
                                <p className="text-gray-600 mb-4 italic">{selectedProvince.details}</p>
                            )}
                            <div className="bg-blue-50 p-4 rounded-md">
                                <h3 className="font-semibold text-blue-700 mb-2">Province Information</h3>
                                <p className="text-sm text-gray-600">
                                    Additional information about {selectedProvince.name} would be displayed here.
                                </p>
                            </div>
                            <div className="mt-4 text-xs text-gray-400 text-center">
                                Press ESC or click outside to close
                            </div>
                        </div>
                    </>
                )}
            </div>
            <div className="w-full md:w-1/3 min-h-[300px] md:h-full overflow-y-auto border-t md:border-t-0 md:border-l border-gray-200 p-4 md:p-6 space-y-6">
                <h2 className="text-2xl font-bold mb-6 text-blue-700">Charts & Indicators</h2>
                <div className="shadow rounded-lg p-4">
                    <div className="mb-2">
                        <h3 className="text-lg font-semibold text-blue-700">Population Density & Indicators</h3>
                        <p className="text-xs text-gray-500">Top 8 provinces by density, literacy, and employment</p>
                    </div>
                    <ResponsiveContainer width="100%" height={240}>
                        <BarChart
                            data={[
                                { province: 'Kabul', density: 1200, literacy: 85, employment: 70 },
                                { province: 'Herat', density: 800, literacy: 78, employment: 65 },
                                { province: 'Balkh', density: 600, literacy: 75, employment: 60 },
                                { province: 'Kandahar', density: 400, literacy: 68, employment: 55 },
                                { province: 'Nangarhar', density: 350, literacy: 65, employment: 52 },
                                { province: 'Kunduz', density: 320, literacy: 62, employment: 50 },
                                { province: 'Parwan', density: 310, literacy: 70, employment: 58 },
                                { province: 'Ghazni', density: 300, literacy: 60, employment: 48 }
                            ]}
                            margin={{ top: 20, right: 20, left: 10, bottom: 10 }}
                        >
                            <XAxis dataKey="province" />
                            <YAxis />
                            <Tooltip />
                            <Legend />
                            <Bar dataKey="density" fill="#2563eb" name="Density" />
                            <Bar dataKey="literacy" fill="#fbbf24" name="Literacy (%)" />
                            <Bar dataKey="employment" fill="#22c55e" name="Employment (%)" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
                <div className="bg-white shadow rounded-lg p-4">
                    <div className="mb-2">
                        <h3 className="text-lg font-semibold text-yellow-700">Resource Distribution</h3>
                        <p className="text-xs text-gray-500">Share of key resources in 2024</p>
                    </div>
                    <ResponsiveContainer width="100%" height={300}>
                        <PieChart>
                            <Pie
                                data={[
                                    { name: 'Water', value: 400 },
                                    { name: 'Electricity', value: 300 },
                                    { name: 'Internet', value: 250 },
                                    { name: 'Healthcare', value: 200 },
                                    { name: 'Education', value: 180 }
                                ]}
                                dataKey="value"
                                nameKey="name"
                                cx="50%"
                                cy="50%"
                                outerRadius={70}
                                label
                            >
                                {/* Different colors for each slice */}
                                <Cell fill="#3b82f6" />
                                <Cell fill="#fbbf24" />
                                <Cell fill="#22c55e" />
                                <Cell fill="#a21caf" />
                                <Cell fill="#ef4444" />
                            </Pie>
                            <Tooltip />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>

                {/* Line Chart Card */}
                <div className="bg-white shadow rounded-lg p-4">
                    <div className="mb-2">
                        <h3 className="text-lg font-semibold text-green-700">Yearly Growth Trends</h3>
                        <p className="text-xs text-gray-500">Population & GDP growth (2020-2025)</p>
                    </div>
                    <ResponsiveContainer width="100%" height={200}>
                        <LineChart
                            data={[
                                { year: 2020, population: 2.1, gdp: 1.2 },
                                { year: 2021, population: 2.5, gdp: 1.4 },
                                { year: 2022, population: 3.0, gdp: 1.7 },
                                { year: 2023, population: 2.7, gdp: 1.9 },
                                { year: 2024, population: 3.2, gdp: 2.2 },
                                { year: 2025, population: 3.5, gdp: 2.5 }
                            ]}
                            margin={{ top: 20, right: 20, left: 10, bottom: 10 }}
                        >
                            <XAxis dataKey="year" />
                            <YAxis />
                            <Tooltip />
                            <Legend />
                            <Line type="monotone" dataKey="population" stroke="#22c55e" strokeWidth={2} name="Population Growth" />
                            <Line type="monotone" dataKey="gdp" stroke="#6366f1" strokeWidth={2} name="GDP Growth" />
                        </LineChart>
                    </ResponsiveContainer>
                </div>

                {/* Complex Chart Card: Stacked Bar + Line */}
                <div className="bg-white shadow rounded-lg p-4">
                    <div className="mb-2">
                        <h3 className="text-lg font-semibold text-purple-700">Education & Health vs GDP</h3>
                        <p className="text-xs text-gray-500">Comparing education, health, and GDP by province</p>
                    </div>
                    <ResponsiveContainer width="100%" height={240}>
                        <ComposedChart
                            data={[
                                { province: 'Kabul', education: 80, health: 70, gdp: 2.1 },
                                { province: 'Herat', education: 65, health: 60, gdp: 1.8 },
                                { province: 'Balkh', education: 60, health: 55, gdp: 1.2 },
                                { province: 'Kandahar', education: 55, health: 50, gdp: 1.0 },
                                { province: 'Nangarhar', education: 50, health: 45, gdp: 0.9 }
                            ]}
                            margin={{ top: 20, right: 20, left: 10, bottom: 10 }}
                        >
                            <XAxis dataKey="province" />
                            <YAxis yAxisId="left" label={{ value: 'Score (%)', angle: -90, position: 'insideLeft' }} />
                            <YAxis yAxisId="right" orientation="right" label={{ value: 'GDP (Billion $)', angle: 90, position: 'insideRight' }} />
                            <Tooltip />
                            <Legend />
                            <Bar yAxisId="left" dataKey="education" fill="#6366f1" name="Education" />
                            <Bar yAxisId="left" dataKey="health" fill="#f59e42" name="Health" />
                            <Line yAxisId="right" type="monotone" dataKey="gdp" stroke="#22c55e" strokeWidth={2} name="GDP" />
                        </ComposedChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

export default Map;