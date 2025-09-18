import { useState, useEffect, useRef, useCallback } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, PieChart, Pie, LineChart, Line, ComposedChart, Cell } from 'recharts';

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// single color + highlight
const CIRCLE_COLOR = '#3b83f6b9';
const HIGHLIGHT_COLOR = '#3b83f6b9';

const getRandomSize = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const getResponsiveZoom = () => {
    if (window.innerWidth < 640) return 4;   // mobile (was 5)
    if (window.innerWidth < 1024) return 5;  // tablet (was 6)
    return 6;                                // desktop (was 7)
};

// predefined province centers (kept from your file)
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

// CirclesLayer: one Circle per province, hover handled on circle itself
const CirclesLayer = ({ circles }) => {
    const map = useMap();

    // bring circles to front after render for visibility
    useEffect(() => {
        const t = setTimeout(() => {
            Object.values(map._layers).forEach(layer => {
                if (layer instanceof L.Circle) layer.bringToFront();
            });
        }, 120);
        return () => clearTimeout(t);
    }, [map, circles]);

    return (
        <>
            {circles.map((c) => (
                <Circle
                    key={c.province}
                    center={c.position}
                    radius={c.radius}
                    pathOptions={{
                        color: CIRCLE_COLOR,
                        fillColor: CIRCLE_COLOR,
                        fillOpacity: 0.75,
                        weight: 2
                    }}
                    // bind tooltip once and handle hover on circle
                    whenCreated={(layer) => {
                        try { layer.bindTooltip(c.province, { direction: 'top', sticky: true }); } catch { console.error("Failed to bind tooltip") }
                    }}
                    eventHandlers={{
                        mouseover: (e) => {
                            const layer = e.target;
                            layer.setStyle({ color: HIGHLIGHT_COLOR, fillColor: HIGHLIGHT_COLOR, fillOpacity: 0.95, weight: 3 });
                            try { layer.bringToFront(); layer.openTooltip(); } catch {
                                console.error("Failed to open tooltip");
                            }
                        },
                        mouseout: (e) => {
                            const layer = e.target;
                            layer.setStyle({ color: CIRCLE_COLOR, fillColor: CIRCLE_COLOR, fillOpacity: 0.75, weight: 2 });
                            try { layer.closeTooltip(); } catch {
                                console.error("Failed to close tooltip");
                            }
                        }
                    }}
                />
            ))}
        </>
    );
};

export default function Map() {
    const [geoData, setGeoData] = useState(null);
    const [circles, setCircles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [zoom, setZoom] = useState(getResponsiveZoom());
    const mapRef = useRef();

    useEffect(() => {
        const onResize = () => setZoom(getResponsiveZoom());
        window.addEventListener('resize', onResize);
        return () => window.removeEventListener('resize', onResize);
    }, []);

    useEffect(() => {
        let cancelled = false;
        fetch('/public/afghanistan-provinces.geojson')
            .then(r => r.json())
            .then(data => {
                if (cancelled) return;
                setGeoData(data);

                const computed = data.features.map((feat) => {
                    const pname = feat.properties.NAME_1 || feat.properties.name || `prov-${Math.random()}`;

                    let center = provinceCenters[pname];
                    if (!center) {
                        const coords = feat.geometry.type === 'Polygon' ? feat.geometry.coordinates[0] : feat.geometry.coordinates[0][0];
                        let sumLng = 0, sumLat = 0, cnt = 0;
                        for (const [lng, lat] of coords) { sumLng += lng; sumLat += lat; cnt++; }
                        center = cnt ? [sumLat / cnt, sumLng / cnt] : [33.9391, 67.7100];
                    }

                    return {
                        province: pname,
                        position: center,
                        radius: getRandomSize(8000, 22000)
                    };
                });

                setCircles(computed);
            })
            .catch(err => console.error(err))
            .finally(() => setLoading(false));

        return () => { cancelled = true; };
    }, []);

    const geoJsonStyle = useCallback(() => ({
        fillColor: '#585754ff',
        weight: 2,
        opacity: 1,
        color: '#dbdbdbff',
        dashArray: '3',
        fillOpacity: 0.4
    }), []);

    if (loading) return <div className="flex items-center justify-center h-screen text-gray-600">Loading map data...</div>;

    return (
        <div className="flex flex-col md:flex-row h-screen min-h-0 w-full">
            <div className="relative min-h-0 h-full w-full md:basis-2/4 md:flex-1 overflow-hidden">
                <ShowInFullScreen
                    modalClassName="w-full h-full max-w-none"
                    previewClassName="relative w-full h-full"
                    containerClassName="w-full h-full p-0 m-0"
                >
                    <MapContainer
                        center={[33.9391, 67.7100]}
                        zoom={zoom}
                        className="w-full h-full min-h-0"
                        whenCreated={m => { mapRef.current = m; }}
                        style={{ width: "100%", height: "100%" }}
                    >
                        <TileLayer
                            attribution='&copy; <a href="https://carto.com/">CartoDB</a> contributors'
                            url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
                        />
                        {geoData && <GeoJSON data={geoData} style={geoJsonStyle()} />}
                        {circles.length > 0 && <CirclesLayer circles={circles} />}
                    </MapContainer>
                </ShowInFullScreen>
            </div>

            <div className="min-h-0 h-full w-full md:basis-2/4 md:flex-1 overflow-y-auto border-t md:border-t-0 md:border-l border-gray-200 p-4 md:p-6 space-y-6 bg-white">
                <h2 className="text-2xl font-bold mb-6 text-blue-700">Charts & Indicators</h2>

                {/* Bar Chart */}
                <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 shadow-sm">
                    <ShowInFullScreen>
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">Population Density by Province</h3>
                            <p className="text-xs text-gray-500">Shows population density, literacy, and employment rates for major provinces.</p>
                        </div>
                        <div id="bar-chart">
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
                    </ShowInFullScreen>
                </div>

                {/* Pie Chart */}
                <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 shadow-sm">
                    <ShowInFullScreen>
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">Access to Basic Services</h3>
                            <p className="text-xs text-gray-500">Pie chart of access to water, electricity, internet, healthcare, and education.</p>
                        </div>
                        <ResponsiveContainer width="100%" height={240}>
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
                    </ShowInFullScreen>
                </div>

                {/* Line Chart */}
                <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 shadow-sm">
                    <ShowInFullScreen>
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">Population & GDP Growth</h3>
                            <p className="text-xs text-gray-500">Line chart showing population and GDP growth over years.</p>
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
                    </ShowInFullScreen>
                </div>

                {/* Composed Chart */}
                <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 shadow-sm">
                    <ShowInFullScreen>
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">Education, Health & GDP by Province</h3>
                            <p className="text-xs text-gray-500">Composed chart showing education, health scores, and GDP for selected provinces.</p>
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
                    </ShowInFullScreen>
                </div>
            </div>
        </div>
    );
}