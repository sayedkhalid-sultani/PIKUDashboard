import { useState, useEffect, useMemo } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import Select from 'react-select';

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

const CIRCLE_COLOR = '#f97316';
const CHORO_DARK = '#08306b';
const CHORO_LIGHT = '#deebf7';
const FIXED_BUBBLE_RADIUS = 12000;

const hexToRgb = (hex) => {
    const v = hex.replace('#', '');
    return [parseInt(v.substring(0, 2), 16), parseInt(v.substring(2, 4), 16), parseInt(v.substring(4, 6), 16)];
};

const rgbToHex = (r, g, b) => '#' + [r, g, b].map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('');

const shadeAround = (baseHex, t) => {
    const baseRgb = hexToRgb(baseHex);
    if (t >= 0) {
        const R = Math.round(baseRgb[0] + (255 - baseRgb[0]) * t);
        const G = Math.round(baseRgb[1] + (255 - baseRgb[1]) * t);
        const B = Math.round(baseRgb[2] + (255 - baseRgb[2]) * t);
        return rgbToHex(R, G, B);
    } else {
        const tt = Math.abs(t);
        const R = Math.round(baseRgb[0] * (1 - tt));
        const G = Math.round(baseRgb[1] * (1 - tt));
        const B = Math.round(baseRgb[2] * (1 - tt));
        return rgbToHex(R, G, B);
    }
};

const rand = (min, max) => Math.random() * (max - min) + min;
const getRandom = (min, max) => Math.random() * (max - min) + min;

const interpHex = (a, b, t) => {
    const A = hexToRgb(a), B = hexToRgb(b);
    const R = Math.round(A[0] + (B[0] - A[0]) * t);
    const G = Math.round(A[1] + (B[1] - A[1]) * t);
    const Bc = Math.round(A[2] + (B[2] - A[2]) * t);
    return rgbToHex(R, G, Bc);
};


// Legend Component for both Choropleth and Bubble
const MapLegends = ({ values, bubbles }) => {
    if (!values || Object.keys(values).length === 0 || !bubbles || bubbles.length === 0) return null;


    const choroplethRanges = [];
    for (let i = 0; i < 5; i++) {
        const from = i * 20; // Start of the range (e.g., 0, 20, 40, ...)
        const to = (i + 1) * 20; // End of the range (e.g., 20, 40, 60, ...)
        const t = (from + to) / 2 / 100; // Normalize to 0-1 for color interpolation
        const color = interpHex(CHORO_LIGHT, CHORO_DARK, t);

        choroplethRanges.push({
            from,
            to,
            color,
        });
    }

    // Bubble Legend Data

    const bubbleRanges = [];
    const bubbleColors = ['#fed7aa', '#fdba74', '#fb923c', '#f97316', '#ea580c'];

    for (let i = 0; i < 5; i++) {
        const from = i * 20; // Start of the range (e.g., 0, 20, 40, ...)
        const to = (i + 1) * 20; // End of the range (e.g., 20, 40, 60, ...)
        bubbleRanges.push({
            from,
            to,
            color: bubbleColors[i],
        });
    }

    return (
        <div className="absolute right-4 top-10 z-1000 flex flex-col space-y-4">
            {/* Choropleth Legend */}
            <div className="bg-white p-3 rounded shadow-lg border border-gray-300 min-w-[180px]">
                <div className="text-sm font-semibold mb-2 text-blue-700">Indicator 1 (Choropleth)</div>
                <div className="space-y-1">
                    {choroplethRanges.map((range, index) => (
                        <div key={index} className="flex items-center">
                            <div
                                className="w-4 h-4 mr-2 border border-gray-300"
                                style={{ backgroundColor: range.color }}
                            ></div>
                            <span className="text-xs text-gray-600 font-medium">
                                {range.from}% - {range.to}%
                            </span>
                        </div>
                    ))}
                </div>
            </div>

            {/* Bubble Legend */}
            <div className="bg-white p-3 rounded shadow-lg border border-gray-300 min-w-[180px]">
                <div className="text-sm font-semibold mb-2 text-orange-600">Indicator 2 (Bubbles)</div>
                <div className="space-y-1">
                    {bubbleRanges.map((range, index) => (
                        <div key={index} className="flex items-center">
                            <div
                                className="w-4 h-4 mr-2 border border-gray-300 rounded-full"
                                style={{ backgroundColor: range.color }}
                            ></div>
                            <span className="text-xs text-gray-600 font-medium">
                                {range.from}% - {range.to}%
                            </span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default function TwoIndicators() {
    const [geoData, setGeoData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [values, setValues] = useState({});
    const [indicator1, setIndicator1] = useState(null);
    const [indicator2, setIndicator2] = useState(null);

    const indicatorOptions = [
        { value: 'population', label: 'Population' },
        { value: 'male_literacy_rate', label: 'Male Literacy Rate' },
        { value: 'gdp', label: 'GDP' },
    ];

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
                    vals[pname] = {
                        i1: Math.round(getRandom(1000, 4500000)),
                        i2: Math.round(getRandom(10, 100))
                    };
                });
                setValues(vals);
            })
            .catch(e => console.error(e))
            .finally(() => setLoading(false));
        return () => { mounted = false; };
    }, []);

    const { colorMap, bubbles } = useMemo(() => {
        if (!geoData) return { colorMap: {}, bubbles: [] };
        const provinces = geoData.features.map(f => f.properties.NAME_1);
        const v1 = provinces.map(p => values[p] ? values[p].i1 : 0);
        const min = Math.min(...v1.map(v => v || 0));
        const max = Math.max(...v1.map(v => v || 0)) || 1;

        const map = {};
        const bubbleArr = [];

        geoData.features.forEach((f) => {
            const pname = f.properties.NAME_1;
            const val = values[pname] ? values[pname].i1 : min;
            const t = (val - min) / Math.max(1, (max - min));
            map[pname] = interpHex(CHORO_LIGHT, CHORO_DARK, t);

            const center = provinceCenters[pname] || (() => {
                const coords = f.geometry.type === 'Polygon' ? f.geometry.coordinates[0] : f.geometry.coordinates[0][0];
                let sumLat = 0, sumLng = 0, cnt = 0;
                coords.forEach(c => { sumLng += c[0]; sumLat += c[1]; cnt++; });
                return cnt ? [sumLat / cnt, sumLng / cnt] : [33.9391, 67.71];
            })();
            const i2 = values[pname] ? values[pname].i2 : 0;

            const shadeT = rand(-0.45, 0.45);
            const circleShade = shadeAround(CIRCLE_COLOR, shadeT);

            const r = FIXED_BUBBLE_RADIUS;
            bubbleArr.push({ province: pname, position: center, radius: r, value: i2, color: circleShade });
        });

        return { colorMap: map, bubbles: bubbleArr };
    }, [geoData, values]);

    if (loading) return <div className="flex items-center justify-center h-full text-gray-600">Loading map...</div>;

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

    const styleForFeature = (feature) => {
        const pname = feature.properties.NAME_1;
        const fill = colorMap[pname] || CHORO_LIGHT;
        return {
            fillColor: fill,
            weight: 3,
            opacity: 1,
            color: CHORO_LIGHT,
            dashArray: '5, 5, 5',
            fillOpacity: 0.85,
        };
    };

    const circleEventHandlers = (b) => ({
        mouseover: (e) => {
            const layer = e.target;
            const hoverShade = shadeAround(b.color, 0.18);
            const orig = (layer.options && layer.options._origRadius) || layer.getRadius();
            layer.setStyle({
                color: hoverShade,
                fillColor: hoverShade,
                fillOpacity: 0.98,
                weight: 10
            });
            try {
                layer.setRadius(orig * 1.08);
                layer.bringToFront();
                layer.bindTooltip(`${b.province}: ${b.value}<br>${getRandomText()}`, { direction: 'top', sticky: true }).openTooltip();
            } catch {
                console.error("Error on mouseover");
            }
        },
        mouseout: (e) => {
            const layer = e.target;
            const orig = (layer.options && layer.options._origRadius) || layer.getRadius();
            layer.setStyle({
                color: b.color,
                fillColor: b.color,
                fillOpacity: 0.85,
                weight: 1
            });
            try {
                layer.setRadius(orig);
                layer.closeTooltip();
            } catch {
                console.error("Error on mouseout");
            }
        }
    });

    const geoJsonEventHandlers = (feature, layer) => {
        layer.on({
            mouseover: () => {
                layer.setStyle({
                    color: CHORO_DARK, // Green border on hover
                    weight: 5, // Increased border size on hover
                });
            },
            mouseout: () => {
                layer.setStyle({
                    color: '#ffffff', // Reset to white border
                    weight: 2, // Reset border size
                });
            },
        });
    };

    return (
        <div className="flex h-full w-full overflow-hidden">
            {/* Scrollable sidebar */}
            <div className="w-full md:w-1/5 flex flex-col gap-4 overflow-y-auto p-4 mb-10 bg-gray-50">
                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h2 className="text-lg font-semibold text-blue-700 mb-2">Please select the indicators</h2>
                    <p className="text-gray-500 text-xs">
                        Choose two indicators from the dropdowns below to visualize and compare data for Afghanistan provinces.
                    </p>
                </div>

                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h3 className="text-sm font-bold text-blue-700 mb-2">Indicator 1</h3>
                    <Select
                        options={indicatorOptions}
                        value={indicator1}
                        onChange={(selectedOption) => setIndicator1(selectedOption)}
                        placeholder="Select Indicator 1"
                        className="mb-4"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                            }),
                        }}

                    />
                    <label className="text-blue-700 font-medium block mb-1 text-xs">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-2 py-1 min-h-[60px] text-xs focus:outline-none focus:ring-2 focus:ring-blue-400"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>

                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h3 className="text-sm font-bold text-orange-500 mb-2">Indicator 2</h3>
                    <Select
                        options={indicatorOptions}
                        value={indicator2}
                        onChange={(selectedOption) => setIndicator2(selectedOption)}
                        placeholder="Select Indicator 2"
                        className="mb-4"
                        styles={{
                            control: (base) => ({
                                ...base,
                                minHeight: 28,
                                fontSize: 12,
                                borderColor: '#f97316',
                                '&:hover': { borderColor: '#ea580c' },
                            }),
                        }}
                    />
                    <label className="text-orange-500 font-medium block mb-1 text-xs">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-2 py-1 min-h-[60px] text-xs focus:outline-none focus:ring-2 focus:ring-orange-400"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>
            </div>

            {/* Map container - fixed, no scrolling */}
            <div className="md:w-4/5 flex-1 overflow-hidden relative">
                <div className="w-full h-full">
                    <ShowInFullScreen
                        modalClassName="w-full h-full"
                        previewClassName="relative w-full h-full"
                        containerClassName="w-full h-full"
                        contentClassName="w-full h-full flex justify-center items-center"
                    >
                        <MapContainer
                            key={`country-map-${geoData ? geoData.features.length : 0}`}
                            center={[33.9391, 67.7100]}
                            zoom={6}
                            style={{ width: '100%', height: '90%' }}
                            zoomSnap={0.3}
                            zoomDelta={0.3}
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
                                    onEachFeature={geoJsonEventHandlers}
                                />
                            )}
                            {bubbles.map((b) => (
                                <Circle
                                    key={`${b.province}-${b.value}`}
                                    center={b.position}
                                    radius={b.radius}
                                    pathOptions={{
                                        color: b.color,
                                        fillColor: b.color,
                                        fillOpacity: 0.85,
                                        weight: 1,
                                    }}
                                    eventHandlers={circleEventHandlers(b)}
                                />
                            ))}
                            <MapLegends colorMap={colorMap} values={values} bubbles={bubbles} />
                        </MapContainer>
                    </ShowInFullScreen>
                </div>
            </div>
        </div>
    );
}