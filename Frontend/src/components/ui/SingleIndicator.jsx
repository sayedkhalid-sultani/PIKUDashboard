import React, { useState, useEffect, useMemo } from 'react';
import { MapContainer, GeoJSON, TileLayer } from 'react-leaflet';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, PieChart, Pie, LineChart, Line, ComposedChart, Cell } from 'recharts';
import { ExportAsExcelHtml } from '../../utils/downloadHelper';
import 'leaflet/dist/leaflet.css';
import Select from 'react-select'; // Import react-select

const CHORO_DARK = '#08306b'; // dark blue
const CHORO_LIGHT = '#deebf7'; // light blue

const provinceStyleBase = (fillColor) => ({
    fillColor,
    weight: 1,
    opacity: 1,
    color: '#ffffff',
    dashArray: '',
    fillOpacity: 0.85
});

const hexToRgb = (hex) => {
    const v = hex.replace('#', '');
    return [parseInt(v.substring(0, 2), 16), parseInt(v.substring(2, 4), 16), parseInt(v.substring(4, 6), 16)];
};

const rgbToHex = (r, g, b) => '#' + [r, g, b].map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('');

const interpHex = (a, b, t) => {
    const A = hexToRgb(a), B = hexToRgb(b);
    const R = Math.round(A[0] + (B[0] - A[0]) * t);
    const G = Math.round(A[1] + (B[1] - A[1]) * t);
    const Bc = Math.round(A[2] + (B[2] - A[2]) * t);
    return rgbToHex(R, G, Bc);
};

const randomText = [
    "Population is growing rapidly.",
    "Literacy rate is improving.",
    "Economic growth is steady.",
    "Healthcare facilities are expanding.",
    "Infrastructure development is ongoing.",
    "Tourism is increasing.",
    "Agriculture is flourishing.",
    "Technology adoption is rising."
];

const getRandomText = () => randomText[Math.floor(Math.random() * randomText.length)];

const provinceOptions = [
    { value: 'Kabul', label: 'Kabul' },
    { value: 'Herat', label: 'Herat' },
    { value: 'Badakhshan', label: 'Badakhshan' },
    { value: 'Kandahar', label: 'Kandahar' },
    { value: 'Nangarhar', label: 'Nangarhar' },
];

const districtOptions = [
    { value: 'Musayee', label: 'Musayee' },
    { value: 'Paghman', label: 'Paghman' },
    { value: 'DehSabz', label: 'DehSabz' },
];

const indicatorOptions = [
    { value: 'population', label: 'Population' },
    { value: 'male_literacy_rate', label: 'Male Literacy Rate' },
    { value: 'gdp', label: 'GDP' },
];

function SingleIndicator() {
    const [geoData, setGeoData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [values, setValues] = useState({}); // { province: value }
    const [selectedIndicator, setSelectedIndicator] = useState(null);
    const [selectedProvince, setSelectedProvince] = useState(null);
    const [selectedDistrict, setSelectedDistrict] = useState(null);

    useEffect(() => {
        let mounted = true;
        fetch('/public/afghanistan-provinces.geojson')
            .then(res => res.json())
            .then(data => {
                if (!mounted) return;
                setGeoData(data);

                const vals = {};
                data.features.forEach((f, idx) => {
                    const pname = f.properties.NAME_1 || `prov-${idx}`;
                    vals[pname] = Math.round(Math.random() * 10000); // Random value for demonstration
                });
                setValues(vals);
            })
            .catch(e => console.error(e))
            .finally(() => setLoading(false));
        return () => { mounted = false; };
    }, []);

    const colorMap = useMemo(() => {
        if (!geoData) return {};
        const provinces = geoData.features.map(f => f.properties.NAME_1);
        const v1 = provinces.map(p => values[p] || 0);
        const min = Math.min(...v1);
        const max = Math.max(...v1) || 1;

        const map = {};
        geoData.features.forEach((f) => {
            const pname = f.properties.NAME_1;
            const val = values[pname] || min;
            const t = (val - min) / Math.max(1, (max - min)); // Normalize value to 0..1
            map[pname] = interpHex(CHORO_DARK, CHORO_LIGHT, t);
        });

        return map;
    }, [geoData, values]);

    if (loading) return <div className="flex items-center justify-center h-screen text-gray-600">Loading map...</div>;

    const styleForFeature = (feature) => {
        const pname = feature.properties.NAME_1;
        const fill = colorMap[pname] || CHORO_LIGHT;
        return provinceStyleBase(fill);
    };

    const onEachFeature = (feature, layer) => {
        layer.on({
            mouseover: () => {
                const hoverText = getRandomText();
                layer.bindTooltip(
                    `<div style="font-size: 16px; font-weight: bold; padding: 8px; color: #0f172a;">
                        ${feature.properties.NAME_1}<br>${hoverText}
                    </div>`,
                    { direction: 'top', sticky: true }
                ).openTooltip();
            },
            mouseout: () => {
                layer.closeTooltip();
            }
        });
    };

    return (
        <div className="flex h-full w-full min-h-0">

            <div className="w-full md:w-2/7 flex-none min-h-0 flex flex-col  overflow-y-auto">
                <div className="w-full bg-white px-6 flex flex-col mb-15 ">
                    <div className="w-full bg-white  flex flex-col mt-4">
                        <h2 className="text-2xl font-bold text-blue-700">Please select the indicator</h2>
                        <p className="text-gray-500 text-base mt-1">
                            Choose the indicator from the dropdowns below to visualize and compare data for Afghanistan provinces.
                        </p>
                    </div>
                    <Select
                        options={indicatorOptions}
                        value={selectedIndicator}
                        onChange={setSelectedIndicator}
                        placeholder="Search and select an indicator"
                        isSearchable
                        className="mb-4"
                    />
                    <h3 className="text-lg font-bold text-blue-700 mb-2">Year</h3>
                    <Select
                        options={[
                            { value: '2020', label: '2020' },
                            { value: '2021', label: '2021' },
                            { value: '2022', label: '2022' }
                        ]}
                        value={null}
                        onChange={() => { }}
                        placeholder="Select year"
                        isSearchable={false}
                        className="mb-4"
                    />
                    <h3 className="text-lg font-bold text-blue-700 mb-2">Province</h3>
                    <Select
                        options={provinceOptions}
                        value={selectedProvince}
                        onChange={setSelectedProvince}
                        placeholder="Search and select a province"
                        isSearchable
                        className="mb-4"
                    />
                    <h3 className="text-lg font-bold text-blue-700 mb-2">District</h3>
                    <Select
                        options={districtOptions}
                        value={selectedDistrict}
                        onChange={setSelectedDistrict}
                        placeholder="Search and select a district"
                        isSearchable
                        className="mb-4"
                    />

                    <label className="text-blue-700 font-semibold ">Value</label>
                    <div className="w-full h-1 rounded bg-gradient-to-r from-blue-500 to-orange-400" />
                    <label className="text-blue-700 font-semibold mb-2">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-4 py-2 min-h-[80px] focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>
            </div>

            {/* Map */}
            <div className="md:w-3/7 flex-1 min-h-0 h-full">

                <ShowInFullScreen
                    modalClassName="w-full h-full"
                    previewClassName="relative w-full h-full"
                    containerClassName="w-full h-full"
                    contentClassName='w-full h-full flex justify-center items-center'
                >
                    <MapContainer
                        key={`single-indicator-map-${geoData ? geoData.features.length : 0}`}
                        center={[33.9391, 67.7100]}
                        zoom={5}
                        className="w-full h-full"
                        style={{ width: "100%", height: "90%" }}
                        zoomSnap={0.3} // Adjust zoom snapping to smaller increments
                        zoomDelta={0.3} // Reduce zoom step size for smoother zooming
                        scrollWheelZoom={true} // Enable scroll wheel zoom
                    >
                        <TileLayer
                            attribution='&copy; <a href="https://carto.com/">CartoDB</a> contributors'
                            url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
                        />
                        {geoData && (
                            <GeoJSON
                                data={geoData}
                                style={styleForFeature}
                                onEachFeature={onEachFeature}
                            />
                        )}
                    </MapContainer>
                </ShowInFullScreen>
            </div>
            <div className="w-full md:w-2/7 flex-none min-h-0 flex flex-col overflow-y-auto px-6 mb-10">
                <h2 className="text-2xl font-bold mb-3 text-blue-700">Selected Indicator Charts</h2>
                <ShowInFullScreen
                    title={"Province Indicators"}
                    subtitle={"Bar chart of population density, literacy rate, and employment rate by province."}
                    source={"Data Source: Afghanistan Statistical Yearbook 2023"}
                    lastUpdate={"Jan 2023"}
                    onExcelDownload={() => {
                        const barChartData = [
                            { province: 'Kabul', density: 1200, literacy: 85, employment: 70 },
                            { province: 'Herat', density: 800, literacy: 78, employment: 65 },
                            { province: 'Balkh', density: 600, literacy: 75, employment: 60 },
                            { province: 'Kandahar', density: 400, literacy: 68, employment: 55 },
                            { province: 'Nangarhar', density: 350, literacy: 65, employment: 52 },
                            { province: 'Kunduz', density: 320, literacy: 62, employment: 50 },
                            { province: 'Parwan', density: 310, literacy: 70, employment: 58 },
                            { province: 'Ghazni', density: 300, literacy: 60, employment: 48 }
                        ];

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
                >
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
                </ShowInFullScreen>

                {/* Pie Chart */}

                <ShowInFullScreen
                    title={"Access to Basic Services"}
                    subtitle={"Pie chart of access to water, electricity, internet, healthcare, and education."}
                    source={"Data Source: Afghanistan Statistical Yearbook 2023"}
                    lastUpdate={"Jan 2023"}
                    onExcelDownload={() => console.log("Download Excel")}
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
            </div>
        </div>
    );
}

export default SingleIndicator;