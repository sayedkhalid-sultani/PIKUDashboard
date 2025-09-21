import { useState, useEffect, useRef, useCallback } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import { ResponsiveContainer, BarChart, Bar as RechartsBar, XAxis, YAxis, Tooltip, Legend, PieChart, Pie, LineChart, Line, ComposedChart, Cell } from 'recharts';
import { BarChart as MuiBarChart } from '@mui/x-charts/BarChart'; // For MUI X Charts
import { Bar as ChartJSBar } from 'react-chartjs-2'; // For Chart.js
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    Title,
    Tooltip as ChartTooltip,
    Legend as ChartLegend,
} from 'chart.js';

import { ExportAsExcelHtml } from '../../utils/downloadHelper';
const provinceData = [
    { province: 'Kabul', density: 1200, literacy: 85, employment: 70 },
    { province: 'Herat', density: 800, literacy: 78, employment: 65 },
    { province: 'Balkh', density: 600, literacy: 75, employment: 60 },
    { province: 'Kandahar', density: 400, literacy: 68, employment: 55 },
    { province: 'Nangarhar', density: 350, literacy: 65, employment: 52 },
    { province: 'Kunduz', density: 320, literacy: 62, employment: 50 },
    { province: 'Parwan', density: 310, literacy: 70, employment: 58 },
    { province: 'Ghazni', density: 300, literacy: 60, employment: 48 },
    { province: 'Badakhshan', density: 280, literacy: 55, employment: 45 },
    { province: 'Baghlan', density: 500, literacy: 60, employment: 50 },
    { province: 'Bamyan', density: 200, literacy: 75, employment: 55 },
    { province: 'Daykundi', density: 150, literacy: 70, employment: 50 },
    { province: 'Farah', density: 250, literacy: 50, employment: 40 },
    { province: 'Faryab', density: 300, literacy: 58, employment: 45 },
    { province: 'Ghor', density: 180, literacy: 52, employment: 42 },
    { province: 'Helmand', density: 350, literacy: 48, employment: 38 },
    { province: 'Jowzjan', density: 400, literacy: 60, employment: 50 },
    { province: 'Kapisa', density: 450, literacy: 65, employment: 55 },
    { province: 'Khost', density: 500, literacy: 62, employment: 52 },
    { province: 'Kunar', density: 300, literacy: 55, employment: 45 },
    { province: 'Laghman', density: 350, literacy: 58, employment: 48 },
    { province: 'Logar', density: 400, literacy: 60, employment: 50 },
    { province: 'Nimruz', density: 200, literacy: 50, employment: 40 },
    { province: 'Nuristan', density: 150, literacy: 45, employment: 35 },
    { province: 'Paktia', density: 300, literacy: 55, employment: 45 },
    { province: 'Paktika', density: 250, literacy: 50, employment: 40 },
    { province: 'Panjshir', density: 180, literacy: 70, employment: 60 },
    { province: 'Samangan', density: 220, literacy: 60, employment: 50 },
    { province: 'SariPul', density: 200, literacy: 55, employment: 45 },
    { province: 'Takhar', density: 300, literacy: 58, employment: 48 },
    { province: 'Urozgan', density: 150, literacy: 50, employment: 40 },
    { province: 'Wardak', density: 250, literacy: 55, employment: 45 },
    { province: 'Zabul', density: 200, literacy: 50, employment: 40 }
];
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

// Register Chart.js components
ChartJS.register(CategoryScale, LinearScale, BarElement, Title, ChartTooltip, ChartLegend);

export default function Map() {
    const [geoData, setGeoData] = useState(null);
    const [circles, setCircles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [zoom, setZoom] = useState(getResponsiveZoom());
    const [currentChartData, setCurrentChartData] = useState(null);
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

    const handleShowInMap = (chartTitle, subtitle, chartData) => {
        // Set the current chart data
        setCurrentChartData({
            title: chartTitle,
            subtitle: subtitle,
            data: chartData,
        });

        // Generate circles or markers for the map based on the chart data
        const updatedCircles = chartData.map((item) => {
            const provinceCenter = provinceCenters[item.province];
            const tooltipContent = Object.keys(item)
                .map(key => `<strong>${key.charAt(0).toUpperCase() + key.slice(1)}:</strong> ${item[key] || 'N/A'}`)
                .join('<br />');

            return {
                province: item.province,
                position: provinceCenter || [33.9391, 67.7100], // Default to Afghanistan center if no province center is found
                radius: item.density ? item.density * 30 : 10000, // Scale the radius based on density or use a default
                tooltip: `<div>${tooltipContent}</div>`
            };
        });

        setCircles(updatedCircles); // Update the circles on the map
    };

    if (loading) return <div className="flex items-center justify-center h-screen text-gray-600">Loading map data...</div>;

    return (
        <div className="flex flex-col md:flex-row h-screen min-h-0 w-full">
            <div className="relative min-h-0 h-full w-full md:basis-2/4 md:flex-1 overflow-hidden">
                {/* Chart Data Display Banner */}
                {currentChartData && (
                    <div className="absolute top-4 left-1/2 transform -translate-x-1/2 z-[1000] bg-white bg-opacity-90 border border-blue-200 rounded-lg shadow-lg p-3 max-w-md">
                        <div className="flex justify-between items-center">
                            <h3 className="text-sm font-bold text-blue-700">{currentChartData?.title}</h3>
                            <button
                                onClick={() => setCurrentChartData(null)}
                                className="text-gray-500 hover:text-gray-700 ml-2"
                            >
                                ✕
                            </button>
                        </div>
                        <p className="text-xs text-gray-600 mt-1">
                            {currentChartData?.subtitle}
                        </p>
                    </div>
                )}

                <ShowInFullScreen
                    modalClassName="w-full h-full"
                    previewClassName="relative w-full h-full"
                    containerClassName="w-full h-full flex justify-center items-center"
                >
                    <MapContainer
                        center={[33.9391, 67.7100]}
                        zoom={zoom}
                        className="w-full h-full"
                        whenCreated={m => { mapRef.current = m; }}
                        style={{ width: "100%", height: "90%" }}
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
                <ShowInFullScreen
                    title={"Province Indicators"}
                    subtitle={"Bar chart of population density, literacy rate, and employment rate by province."}
                    showInMapSelected={currentChartData?.title === "Province Indicators"}
                    onExcelDownload={() => {
                        const barChartData = provinceData;

                        // Transform the data to match the Excel format
                        const excelData = barChartData.map(item => ({
                            province: item.province,
                            density: item.density,
                            literacy: `${item.literacy}%`,
                            employment: `${item.employment}%`
                        }));

                        // Call the helper function
                        ExportAsExcelHtml(excelData, "Province Indicators Report", "province-indicators");
                    }}
                    onShowInMap={() => handleShowInMap(
                        "Province Indicators",
                        "Bar chart of population density, literacy rate, and employment rate by province.",
                        provinceData
                    )}
                >
                    <ResponsiveContainer width={1200} height={300}>
                        <BarChart
                            data={provinceData}
                            margin={{ top: 20, right: 20, left: 10, bottom: 10 }}
                        >
                            <XAxis
                                dataKey="province"
                                angle={45}
                                textAnchor="start"
                                interval={0}
                                height={80}
                            />
                            <YAxis />
                            <Tooltip />
                            <Legend />
                            <RechartsBar dataKey="density" fill="#2563eb" name="Density" />
                            <RechartsBar dataKey="literacy" fill="#fbbf24" name="Literacy (%)" />
                            <RechartsBar dataKey="employment" fill="#22c55e" name="Employment (%)" />
                        </BarChart>
                    </ResponsiveContainer>
                </ShowInFullScreen>

                {/* New Bar Chart using MUI X Charts */}
                {/* <ShowInFullScreen
                    title={"Province Indicators"}
                    subtitle={"Bar chart of population density, literacy rate, and employment rate by province."}
                    showInMapSelected={currentChartData?.title === "Province Indicators"}
                    onExcelDownload={() => {
                        const barChartData = provinceData;

                        // Transform the data to match the Excel format
                        const excelData = barChartData.map(item => ({
                            province: item.province,
                            density: item.density,
                            literacy: `${item.literacy}%`,
                            employment: `${item.employment}%`
                        }));

                        // Call the helper function
                        ExportAsExcelHtml(excelData, "Province Indicators Report", "province-indicators");
                    }}
                    onShowInMap={() => handleShowInMap(
                        "Province Indicators",
                        "Bar chart of population density, literacy rate, and employment rate by province.",
                        provinceData
                    )}
                >   <MuiBarChart
                        xAxis={[{ dataKey: 'province', label: 'Province' }]}
                        series={[
                            { dataKey: 'density', label: 'Density', color: '#2563eb' },
                            { dataKey: 'literacy', label: 'Literacy (%)', color: '#fbbf24' },
                            { dataKey: 'employment', label: 'Employment (%)', color: '#22c55e' },
                        ]}
                        dataset={provinceData} // Explicitly provide the dataset
                        width={800}
                        height={400}
                    />
                </ShowInFullScreen> */}

                {/* New Bar Chart using Chart.js */}
                {/* <ShowInFullScreen
                    title={"Province Indicators"}
                    subtitle={"Bar chart of population density, literacy rate, and employment rate by province."}
                    showInMapSelected={currentChartData?.title === "Province Indicators"}
                    onExcelDownload={() => {
                        const barChartData = provinceData;

                        // Transform the data to match the Excel format
                        const excelData = barChartData.map(item => ({
                            province: item.province,
                            density: item.density,
                            literacy: `${item.literacy}%`,
                            employment: `${item.employment}%`
                        }));

                        // Call the helper function
                        ExportAsExcelHtml(excelData, "Province Indicators Report", "province-indicators");
                    }}
                    onShowInMap={() => handleShowInMap(
                        "Province Indicators",
                        "Bar chart of population density, literacy rate, and employment rate by province.",
                        provinceData
                    )}
                >
                    <ChartJSBar
                        data={{
                            labels: provinceData.map(item => item.province),
                            datasets: [
                                {
                                    label: 'Density',
                                    data: provinceData.map(item => item.density),
                                    backgroundColor: '#2563eb',
                                },
                                {
                                    label: 'Literacy (%)',
                                    data: provinceData.map(item => item.literacy),
                                    backgroundColor: '#fbbf24',
                                },
                                {
                                    label: 'Employment (%)',
                                    data: provinceData.map(item => item.employment),
                                    backgroundColor: '#22c55e',
                                },
                            ],
                        }}
                        options={{
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'top',
                                },
                                title: {
                                    display: true,
                                    text: 'Province Indicators (Chart.js)',
                                },
                            },
                        }}
                    />
                </ShowInFullScreen> */}
                {/* Pie Chart */}

                <ShowInFullScreen title={"Access to Basic Services"} subtitle={"Pie chart of access to water, electricity, internet, healthcare, and education."}
                    onExcelDownload={() => console.log("Download Excel")}
                    onShowInMap={() => handleShowInMap(
                        "Access to Basic Services",
                        "Pie chart of access to water, electricity, internet, healthcare, and education.",
                        [
                            { name: 'Water', value: 400 },
                            { name: 'Electricity', value: 300 },
                            { name: 'Internet', value: 250 },
                            { name: 'Healthcare', value: 200 },
                            { name: 'Education', value: 180 }
                        ]
                    )}
                    showInMapSelected={currentChartData?.title === "Access to Basic Services"}
                >
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

                {/* Line Chart */}

                <ShowInFullScreen title={"Population & GDP Growth Over Years"} subtitle={"Line chart showing population and GDP growth over years."}
                    onExcelDownload={() => console.log("Download Excel")}
                    onShowInMap={() => handleShowInMap(
                        "Population & GDP Growth",
                        "Line chart showing population and GDP growth over years.",
                        [
                            { year: 2020, population: 2.1, gdp: 1.2 },
                            { year: 2021, population: 2.5, gdp: 1.4 },
                            { year: 2022, population: 3.0, gdp: 1.7 },
                            { year: 2023, population: 2.7, gdp: 1.9 },
                            { year: 2024, population: 3.2, gdp: 2.2 },
                            { year: 2025, population: 3.5, gdp: 2.5 }
                        ]
                    )}
                    showInMapSelected={currentChartData?.title === "Population & GDP Growth"}
                >
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

                {/* Composed Chart */}
                <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 shadow-sm">
                    <ShowInFullScreen title={"Education, Health & GDP by Province"} subtitle={"Composed chart showing education, health scores, and GDP for selected provinces."}
                        onShowInMap={() => handleShowInMap(
                            "Education, Health & GDP",
                            "Composed chart showing education, health scores, and GDP for selected provinces.",
                            [
                                { province: 'Kabul', education: 80, health: 70, gdp: 2.1 },
                                { province: 'Herat', education: 65, health: 60, gdp: 1.8 },
                                { province: 'Balkh', education: 60, health: 55, gdp: 1.2 },
                                { province: 'Kandahar', education: 55, health: 50, gdp: 1.0 },
                                { province: 'Nangarhar', education: 50, health: 45, gdp: 0.9 }
                            ]
                        )}
                        showInMapSelected={currentChartData?.title === "Education, Health & GDP"}
                        onExcelDownload={() => console.log("Download Excel")}
                    >
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
                                <RechartsBar yAxisId="left" dataKey="education" fill="#6366f1" name="Education" />
                                <RechartsBar yAxisId="left" dataKey="health" fill="#f59e42" name="Health" />
                                <Line yAxisId="right" type="monotone" dataKey="gdp" stroke="#22c55e" strokeWidth={2} name="GDP" />
                            </ComposedChart>
                        </ResponsiveContainer>
                    </ShowInFullScreen>
                </div>
            </div >
        </div >
    );
}