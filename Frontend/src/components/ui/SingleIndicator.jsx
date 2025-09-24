import React, { useState, useEffect, useMemo } from 'react';
import { MapContainer, GeoJSON, TileLayer } from 'react-leaflet';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, PieChart, Pie, ComposedChart, Cell } from 'recharts';
import { ExportAsExcelHtml } from '../../utils/downloadHelper';
import 'leaflet/dist/leaflet.css';
import Select from 'react-select';

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

// const randomText = [
//     "Population is growing rapidly.",
//     "Literacy rate is improving.",
//     "Economic growth is steady.",
//     "Healthcare facilities are expanding.",
//     "Infrastructure development is ongoing.",
//     "Tourism is increasing.",
//     "Agriculture is flourishing.",
//     "Technology adoption is rising."
// ];

// const getRandomText = () => randomText[Math.floor(Math.random() * randomText.length)];

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

// Legend component
const ChoroplethLegend = ({ values }) => {
    if (!values || Object.keys(values).length === 0) return null;

    // Create 5 equal groups
    const rangeSize = 100 / 5; // Divide into 5 groups (20% each)
    const ranges = [];

    for (let i = 0; i < 5; i++) {
        const from = i * rangeSize;
        const to = (i + 1) * rangeSize;

        // Calculate color for this range (use midpoint)
        const t = (from + to) / 2 / 100; // Normalize to 0-1 for color interpolation
        const color = interpHex(CHORO_LIGHT, CHORO_DARK, t);

        ranges.push({
            from: Math.round(from),
            to: Math.round(to),
            color: color,
        });
    }

    return (
        <div className="absolute bottom-4 right-2 z-1000 bg-white p-3 rounded shadow-md border border-gray-300">
            <div className="text-sm font-semibold mb-2 text-gray-700">Indicator Values (%)</div>
            {ranges.map((range, index) => (
                <div key={index} className="flex items-center mb-1">
                    <div
                        className="w-4 h-4 mr-2 border border-gray-300"
                        style={{ backgroundColor: range.color }}
                    ></div>
                    <span className="text-xs text-gray-600">
                        {range.from === ranges[0].from ? `≤ ${range.to}%` :
                            range.to === ranges[ranges.length - 1].to ? `≥ ${range.from}%` :
                                `${range.from}% - ${range.to}%`}
                    </span>
                </div>
            ))}
        </div>
    );
};

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
            map[pname] = interpHex(CHORO_LIGHT, CHORO_DARK, t);
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
        // const value = values[feature.properties.NAME_1] || 0;

        layer.on({
            mouseover: () => {
                layer.setStyle({
                    color: CHORO_DARK,
                    weight: 5,
                });
                // const hoverText = getRandomText();
                // layer.bindTooltip(
                //     `<div style="font-size: 14px; font-weight: bold; padding: 8px; color: #0f172a; min-width: 150px;">
                //         <div>${feature.properties.NAME_1}</div>
                //         <div style="font-size: 12px; font-weight: normal; margin-top: 4px; color: #475569;">
                //             Value: ${value.toLocaleString()}
                //         </div>
                //         <div style="font-size: 11px; font-style: italic; margin-top: 4px; color: #64748b;">
                //             ${hoverText}
                //         </div>
                //     </div>`,
                //     { direction: 'top', sticky: true, className: 'custom-tooltip' }
                // ).openTooltip();
            },
            mouseout: () => {
                layer.setStyle({
                    color: '#ffffff', // Reset to white border
                    weight: 1, // Reset border size
                });
                layer.closeTooltip();
            },
        });
    };

    return (
        <div className="flex h-full w-full min-h-0">

            {/* Sidebar (smaller, styled) */}
            <div className="w-full md:w-1/5 flex-none min-h-0 flex flex-col overflow-y-auto">
                <div className="w-full bg-white px-3 py-2 flex flex-col mb-8 rounded-lg shadow-sm border border-gray-100">
                    <div className="w-full flex flex-col mt-2 mb-2">
                        <h2 className="text-base font-semibold text-blue-700 mb-1">Select Indicator</h2>
                        <p className="text-xs text-gray-500 mb-2">
                            Choose an indicator to visualize and compare data for Afghanistan provinces.
                        </p>
                    </div>
                    <Select
                        options={indicatorOptions}
                        value={selectedIndicator}
                        onChange={setSelectedIndicator}
                        placeholder="Indicator"
                        isSearchable
                        className="mb-2 text-xs"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                            }),
                            valueContainer: (base) => ({
                                ...base,
                                padding: '0 6px',
                            }),
                            input: (base) => ({
                                ...base,
                                margin: 0,
                                padding: 0,
                            }),
                            indicatorsContainer: (base) => ({
                                ...base,
                                height: 28,
                            }),
                        }}
                    />
                    <h3 className="text-sm font-semibold text-blue-700 mb-1 mt-2">Year</h3>
                    <Select
                        options={[
                            { value: '2020', label: '2020' },
                            { value: '2021', label: '2021' },
                            { value: '2022', label: '2022' }
                        ]}
                        value={null}
                        onChange={() => { }}
                        placeholder="Year"
                        isSearchable={false}
                        className="mb-2 text-xs"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                            }),
                            valueContainer: (base) => ({
                                ...base,
                                padding: '0 6px',
                            }),
                            input: (base) => ({
                                ...base,
                                margin: 0,
                                padding: 0,
                            }),
                            indicatorsContainer: (base) => ({
                                ...base,
                                height: 28,
                            }),
                        }}
                    />
                    <h3 className="text-sm font-semibold text-blue-700 mb-1 mt-2">Province</h3>
                    <Select
                        options={provinceOptions}
                        value={selectedProvince}
                        onChange={setSelectedProvince}
                        placeholder="Province"
                        isSearchable
                        className="mb-2 text-xs"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                            }),
                            valueContainer: (base) => ({
                                ...base,
                                padding: '0 6px',
                            }),
                            input: (base) => ({
                                ...base,
                                margin: 0,
                                padding: 0,
                            }),
                            indicatorsContainer: (base) => ({
                                ...base,
                                height: 28,
                            }),
                        }}
                    />
                    <h3 className="text-sm font-semibold text-blue-700 mb-1 mt-2">District</h3>
                    <Select
                        options={districtOptions}
                        value={selectedDistrict}
                        onChange={setSelectedDistrict}
                        placeholder="District"
                        isSearchable
                        className="mb-2 text-xs"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                            }),
                            valueContainer: (base) => ({
                                ...base,
                                padding: '0 6px',
                            }),
                            input: (base) => ({
                                ...base,
                                margin: 0,
                                padding: 0,
                            }),
                            indicatorsContainer: (base) => ({
                                ...base,
                                height: 28,
                            }),
                        }}
                    />
                </div>
            </div>

            {/* Map */}
            <div className="md:w-3/5 flex-1 min-h-0 h-full relative">
                <ShowInFullScreen
                    modalClassName="w-full h-full"
                    previewClassName="relative w-full h-full"
                    containerClassName="w-full h-full"
                    contentClassName='w-full h-full flex justify-center items-center'
                >
                    <MapContainer
                        key={`single-indicator-map-${geoData ? geoData.features.length : 0}`}
                        center={[33.9391, 67.7100]}
                        zoom={6}
                        className="w-full h-full"
                        style={{ width: "100%", height: "90%" }}
                        zoomSnap={0.3}
                        zoomDelta={0.3}
                        scrollWheelZoom={true}
                        attributionControl={false}
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
                        <ChoroplethLegend colorMap={colorMap} values={values} />
                    </MapContainer>
                </ShowInFullScreen>

                {/* Choropleth Legend */}
            </div>

            {/* Right panel (charts) */}
            <div className="w-full md:w-1/5 flex-none min-h-0 flex flex-col overflow-y-auto px-4 mb-6">
                <h2 className="text-lg font-bold mb-2 text-blue-700">Selected Indicator Charts</h2>
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

                        const excelData = barChartData.map(item => ({
                            province: item.province,
                            density: item.density,
                            literacy: `${item.literacy}%`,
                            employment: `${item.employment}%`
                        }));

                        ExportAsExcelHtml(excelData, "Province Indicators Report", "province-indicators");
                    }}
                >
                    <ResponsiveContainer width="100%" height={180}>
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
                            margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
                        >
                            <XAxis dataKey="province" tick={{ fontSize: 10 }} />
                            <YAxis tick={{ fontSize: 10 }} />
                            <Tooltip />
                            <Legend wrapperStyle={{ fontSize: 10 }} />
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
                    <ResponsiveContainer width="100%" height={180}>
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
                                outerRadius={50}
                                label={({ name }) => name}
                                labelStyle={{ fontSize: 10 }}
                            >
                                <Cell fill="#3b82f6" />
                                <Cell fill="#fbbf24" />
                                <Cell fill="#22c55e" />
                                <Cell fill="#a21caf" />
                                <Cell fill="#ef4444" />
                            </Pie>
                            <Tooltip />
                            <Legend wrapperStyle={{ fontSize: 10 }} />
                        </PieChart>
                    </ResponsiveContainer>
                </ShowInFullScreen>
            </div>
        </div>
    );
}

export default SingleIndicator;