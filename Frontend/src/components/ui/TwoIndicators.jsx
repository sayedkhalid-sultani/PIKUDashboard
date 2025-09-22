import { useState, useEffect, useMemo } from 'react';
import { MapContainer, GeoJSON, TileLayer, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import Select from 'react-select'; // Import react-select

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

// Change the base color for circles
const CIRCLE_COLOR = '#f97316'; // Orange base color for circles

// helper: convert hex <-> rgb (already present in file, kept here for completeness)
const hexToRgb = (hex) => {
    const v = hex.replace('#', '');
    return [parseInt(v.substring(0, 2), 16), parseInt(v.substring(2, 4), 16), parseInt(v.substring(4, 6), 16)];
};
const rgbToHex = (r, g, b) => '#' + [r, g, b].map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('');

// generate a randomized shade around a base color
// t in [-1,1]: negative -> darker (toward black), positive -> lighter (toward white)
const shadeAround = (baseHex, t) => {
    const baseRgb = hexToRgb(baseHex);
    if (t >= 0) {
        // interpolate toward white
        const R = Math.round(baseRgb[0] + (255 - baseRgb[0]) * t);
        const G = Math.round(baseRgb[1] + (255 - baseRgb[1]) * t);
        const B = Math.round(baseRgb[2] + (255 - baseRgb[2]) * t);
        return rgbToHex(R, G, B);
    } else {
        const tt = Math.abs(t);
        // interpolate toward black
        const R = Math.round(baseRgb[0] * (1 - tt));
        const G = Math.round(baseRgb[1] * (1 - tt));
        const B = Math.round(baseRgb[2] * (1 - tt));
        return rgbToHex(R, G, B);
    }
};

// random in range
const rand = (min, max) => Math.random() * (max - min) + min;

// getRandom: returns a random number between min and max
const getRandom = (min, max) => Math.random() * (max - min) + min;

// interpolate between two hex colors
const interpHex = (a, b, t) => {
    const A = hexToRgb(a), B = hexToRgb(b);
    const R = Math.round(A[0] + (B[0] - A[0]) * t);
    const G = Math.round(A[1] + (B[1] - A[1]) * t);
    const Bc = Math.round(A[2] + (B[2] - A[2]) * t);
    return rgbToHex(R, G, Bc);
};

const CHORO_DARK = '#08306b'; // dark blue
const CHORO_LIGHT = '#deebf7'; // light blue

// add fixed bubble radius constant (fixes ReferenceError)
const FIXED_BUBBLE_RADIUS = 12000;

const provinceStyleBase = (fillColor) => ({
    fillColor,
    weight: 1,
    opacity: 1,
    color: '#ffffff',
    dashArray: '',
    fillOpacity: 0.85
});

export default function TwoIndicators() {
    const [geoData, setGeoData] = useState(null);
    const [loading, setLoading] = useState(true);
    // indicator1 -> choropleth, indicator2 -> bubble size
    const [values, setValues] = useState({}); // { province: {i1, i2} }

    const [indicator1, setIndicator1] = useState(null);
    const [indicator2, setIndicator2] = useState(null);

    // Options for the dropdowns
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

                // generate values per province (replace with real data as needed)
                const vals = {};
                data.features.forEach((f, idx) => {
                    const pname = f.properties.NAME_1 || `prov-${idx}`;
                    // example: indicator1 in range 0..10000, indicator2 0..1e6
                    vals[pname] = {
                        i1: Math.round(getRandom(1000, 4500000)),   // e.g., population-like
                        i2: Math.round(getRandom(10, 100))          // e.g., percentage or score
                    };
                });
                setValues(vals);
            })
            .catch(e => console.error(e))
            .finally(() => setLoading(false));
        return () => { mounted = false; };
    }, []);

    // prepare choropleth color map and bubble array
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
            const t = (val - min) / Math.max(1, (max - min)); // 0..1
            map[pname] = interpHex(CHORO_DARK, CHORO_LIGHT, t);

            // circle: fixed radius but randomized shade based on the new CIRCLE_COLOR
            const center = provinceCenters[pname] || (() => {
                const coords = f.geometry.type === 'Polygon' ? f.geometry.coordinates[0] : f.geometry.coordinates[0][0];
                let sumLat = 0, sumLng = 0, cnt = 0;
                coords.forEach(c => { sumLng += c[0]; sumLat += c[1]; cnt++; });
                return cnt ? [sumLat / cnt, sumLng / cnt] : [33.9391, 67.71];
            })();
            const i2 = values[pname] ? values[pname].i2 : 0;

            // randomize shade around the new base color
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

    // Helper to get random text
    const getRandomText = () => randomText[Math.floor(Math.random() * randomText.length)];

    // GeoJSON style function uses colorMap and adds tooltip with random text
    const styleForFeature = (feature) => {
        const pname = feature.properties.NAME_1;
        const fill = colorMap[pname] || CHORO_LIGHT;
        return provinceStyleBase(fill);
    };

    // Updated Circle hover logic with new color
    const circleEventHandlers = (b) => ({
        mouseover: (e) => {
            const layer = e.target;
            const hoverShade = shadeAround(b.color, 0.18);
            const orig = (layer.options && layer.options._origRadius) || layer.getRadius();
            layer.setStyle({
                color: hoverShade,
                fillColor: hoverShade,
                fillOpacity: 0.98,
                weight: 3
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

    // Updated GeoJSON hover logic with random text
    const geoJsonEventHandlers = (feature, layer) => {
        layer.on({
            mouseover: () => {
                const hoverText = getRandomText();
                layer.bindTooltip(`${feature.properties.NAME_1}<br>${hoverText}`, { direction: 'top', sticky: true }).openTooltip();
            },
            mouseout: () => {
                layer.closeTooltip();
            }
        });
    };

    return (
        <div className="flex h-full w-full overflow-hidden">
            {/* Scrollable sidebar */}
            <div className="w-full md:w-2/7 flex flex-col gap-4 overflow-y-auto p-4 mb-10 bg-gray-50">
                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h2 className="text-xl font-bold text-blue-700 mb-2">Please select the indicators</h2>
                    <p className="text-gray-500 text-sm">
                        Choose two indicators from the dropdowns below to visualize and compare data for Afghanistan provinces.
                    </p>
                </div>

                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h3 className="text-lg font-bold text-blue-700 mb-2">Indicator 1</h3>
                    <Select
                        options={indicatorOptions}
                        value={indicator1}
                        onChange={(selectedOption) => setIndicator1(selectedOption)}
                        placeholder="Select Indicator 1"
                        className="mb-4"
                    />
                    <label className="text-blue-700 font-semibold block mb-1">Value</label>
                    <div className="w-full h-1 rounded bg-gradient-to-r from-blue-500 to-orange-400 mb-2" />
                    <label className="text-blue-700 font-semibold block mb-1">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 min-h-[80px] text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>

                <div className="bg-white rounded-lg shadow-sm p-4">
                    <h3 className="text-lg font-bold text-orange-500 mb-2">Indicator 2</h3>
                    <Select
                        options={indicatorOptions}
                        value={indicator2}
                        onChange={(selectedOption) => setIndicator2(selectedOption)}
                        placeholder="Select Indicator 2"
                        className="mb-4"
                        styles={{
                            control: (base) => ({
                                ...base,
                                borderColor: '#f97316', // Orange border
                                '&:hover': { borderColor: '#ea580c' }, // Darker orange on hover
                            }),
                        }}
                    />
                    <label className="text-orange-500 font-semibold block mb-1">Value</label>
                    <div className="w-full h-1 rounded bg-gradient-to-r from-orange-400 to-blue-500 mb-2" />
                    <label className="text-orange-500 font-semibold block mb-1">Definition</label>
                    <textarea
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 min-h-[80px] text-sm focus:outline-none focus:ring-2 focus:ring-orange-400"
                        defaultValue="You can add your analysis or comments here about the selected indicators and provinces."
                    />
                </div>
            </div>

            {/* Map container - fixed, no scrolling */}
            <div className="md:w-5/7 flex-1 overflow-hidden">
                <div className="w-full h-full">
                    <ShowInFullScreen
                        modalClassName="w-full h-full"
                        previewClassName="relative w-full h-full"
                        containerClassName="w-full h-full"
                        contentClassName='w-full h-full flex justify-center items-center'
                    >
                        <MapContainer
                            key={`country-map-${geoData ? geoData.features.length : 0}`}
                            center={[33.9391, 67.7100]} zoom={6} style={{ width: "100%", height: "90%" }}
                            zoomSnap={0.3}
                            zoomDelta={0.3}

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
                            {bubbles.map(b => (
                                <Circle
                                    key={`${b.province}-${b.value}`}
                                    center={b.position}
                                    radius={b.radius}
                                    pathOptions={{
                                        color: b.color,
                                        fillColor: b.color,
                                        fillOpacity: 0.85,
                                        weight: 1
                                    }}
                                    eventHandlers={circleEventHandlers(b)}
                                />
                            ))}
                        </MapContainer>
                    </ShowInFullScreen>
                </div>
            </div>
        </div>
    );
}