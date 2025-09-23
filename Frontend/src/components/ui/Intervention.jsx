import React, { useState, useEffect } from 'react';
import { MapContainer, GeoJSON, TileLayer, Marker, Popup } from 'react-leaflet';
import { Icon } from 'leaflet';
import ShowInFullScreen from '../shared/ShowInFullScreen';
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, PieChart, Pie, LineChart, Line, Cell } from 'recharts';
import { ExportAsExcelHtml } from '../../utils/downloadHelper';
import 'leaflet/dist/leaflet.css';
import Select from 'react-select';

// Fix for Leaflet marker icons in React
try {
    delete Icon.Default.prototype._getIconUrl;
    Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
        iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
    });
} catch (error) {
    console.warn('Leaflet icon configuration failed:', error);
}

// Indicator options with corresponding chart types
const indicatorOptions = [
    { value: 'population', label: 'Population', chartType: 'bar' },
    { value: 'male_literacy_rate', label: 'Male Literacy Rate', chartType: 'line' },
    { value: 'gdp', label: 'GDP', chartType: 'bar' },
    { value: 'employment_rate', label: 'Employment Rate', chartType: 'pie' },
    { value: 'access_to_services', label: 'Access to Basic Services', chartType: 'pie' },
];

// Sample GPS points data based on projects and interventions
const gpsPointsData = {
    project1: {
        intervention1: [
            { id: 1, lat: 34.5553, lng: 69.2075, name: 'Kabul Site A', year: '2022', value: 1500 },
            { id: 2, lat: 34.5155, lng: 69.1322, name: 'Kabul Site B', year: '2022', value: 1200 }
        ],
        intervention2: [
            { id: 3, lat: 34.3735, lng: 70.3650, name: 'Jalalabad Site', year: '2022', value: 800 }
        ]
    },
    project2: {
        intervention1: [
            { id: 4, lat: 34.3413, lng: 62.2031, name: 'Herat Site A', year: '2021', value: 950 },
            { id: 5, lat: 36.7585, lng: 66.8989, name: 'Balkh Site', year: '2021', value: 1100 }
        ],
        intervention3: [
            { id: 6, lat: 31.6133, lng: 65.7101, name: 'Kandahar Site', year: '2021', value: 750 }
        ]
    },
    project3: {
        intervention2: [
            { id: 7, lat: 35.9446, lng: 68.7156, name: 'Kunduz Site', year: '2020', value: 600 },
            { id: 8, lat: 34.8133, lng: 67.8279, name: 'Bamyan Site', year: '2020', value: 500 }
        ]
    }
};

// Sample chart data based on indicators
const chartData = {
    population: [
        { province: 'Kabul', value: 4635000, year: '2022' },
        { province: 'Herat', value: 1892000, year: '2022' },
        { province: 'Balkh', value: 1347000, year: '2022' },
        { province: 'Kandahar', value: 1222000, year: '2022' },
        { province: 'Nangarhar', value: 1525000, year: '2022' }
    ],
    male_literacy_rate: [
        { province: 'Kabul', value: 65, year: '2022' },
        { province: 'Herat', value: 58, year: '2022' },
        { province: 'Balkh', value: 55, year: '2022' },
        { province: 'Kandahar', value: 48, year: '2022' },
        { province: 'Nangarhar', value: 52, year: '2022' }
    ],
    gdp: [
        { province: 'Kabul', value: 15.2, year: '2022' },
        { province: 'Herat', value: 8.7, year: '2022' },
        { province: 'Balkh', value: 6.3, year: '2022' },
        { province: 'Kandahar', value: 5.8, year: '2022' },
        { province: 'Nangarhar', value: 4.9, year: '2022' }
    ],
    employment_rate: [
        { name: 'Employed', value: 42 },
        { name: 'Unemployed', value: 35 },
        { name: 'Not in Labor Force', value: 23 }
    ],
    access_to_services: [
        { name: 'Water', value: 65 },
        { name: 'Electricity', value: 45 },
        { name: 'Healthcare', value: 55 },
        { name: 'Education', value: 60 }
    ]
};

// Project and intervention options
const projectOptions = [
    { value: 'project1', label: 'Infrastructure Development' },
    { value: 'project2', label: 'Education Enhancement' },
    { value: 'project3', label: 'Healthcare Improvement' },
];

const interventionOptions = {
    project1: [
        { value: 'intervention1', label: 'Road Construction' },
        { value: 'intervention2', label: 'Bridge Building' }
    ],
    project2: [
        { value: 'intervention1', label: 'School Renovation' },
        { value: 'intervention3', label: 'Teacher Training' }
    ],
    project3: [
        { value: 'intervention2', label: 'Clinic Setup' }
    ]
};

const yearOptions = [
    { value: '2020', label: '2020' },
    { value: '2021', label: '2021' },
    { value: '2022', label: '2022' },
];

function Intervention() {
    const [geoData, setGeoData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [selectedIndicator, setSelectedIndicator] = useState(indicatorOptions[0]);
    const [selectedProject, setSelectedProject] = useState(null);
    const [selectedIntervention, setSelectedIntervention] = useState(null);
    const [selectedYear, setSelectedYear] = useState(yearOptions[2]);
    const [availableInterventions, setAvailableInterventions] = useState([]);
    const [gpsPoints, setGpsPoints] = useState([]);

    useEffect(() => {
        let mounted = true;
        fetch('/public/afghanistan-provinces.geojson')
            .then((res) => res.json())
            .then((data) => {
                if (!mounted) return;
                setGeoData(data);
            })
            .catch((e) => console.error(e))
            .finally(() => setLoading(false));
        return () => {
            mounted = false;
        };
    }, []);

    useEffect(() => {
        if (selectedProject) {
            const interventions = interventionOptions[selectedProject.value] || [];
            setAvailableInterventions(interventions);
            setSelectedIntervention(interventions.length > 0 ? interventions[0] : null);
        } else {
            setAvailableInterventions([]);
            setSelectedIntervention(null);
        }
    }, [selectedProject]);

    useEffect(() => {
        if (selectedProject && selectedIntervention && selectedYear) {
            const points = gpsPointsData[selectedProject.value]?.[selectedIntervention.value] || [];
            const filteredPoints = points.filter((point) => point.year === selectedYear.value);
            setGpsPoints(filteredPoints);
        } else {
            setGpsPoints([]);
        }
    }, [selectedProject, selectedIntervention, selectedYear]);

    // Render chart based on selected indicator

    if (loading) return <div className="flex items-center justify-center h-screen text-gray-600">Loading map...</div>;

    return (
        <div className="flex h-full w-full min-h-0">
            {/* Sidebar */}
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
                        options={yearOptions}
                        value={selectedYear}
                        onChange={setSelectedYear}
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
                    <h3 className="text-sm font-semibold text-blue-700 mb-1 mt-2">Project</h3>
                    <Select
                        options={projectOptions}
                        value={selectedProject}
                        onChange={setSelectedProject}
                        placeholder="Project"
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
                    <h3 className="text-sm font-semibold text-blue-700 mb-1 mt-2">Intervention</h3>
                    <Select
                        options={availableInterventions}
                        value={selectedIntervention}
                        onChange={setSelectedIntervention}
                        placeholder={selectedProject ? 'Select intervention' : 'Select a project first'}
                        isSearchable
                        isDisabled={!selectedProject}
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
                    contentClassName="w-full h-full flex justify-center items-center"
                >
                    <MapContainer
                        center={[33.9391, 67.71]}
                        zoom={6}
                        style={{ width: '100%', height: '90%' }}
                        attributionControl={false}
                    >
                        <TileLayer
                            attribution='&copy; <a href="https://carto.com/">CartoDB</a> contributors'
                            url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
                        />
                        {geoData && (
                            <GeoJSON
                                data={geoData}
                                style={() => ({
                                    color: '#9e9e9eff',
                                    weight: 1,
                                    fillColor: '#979797ff',
                                    fillOpacity: 0.3,
                                })}
                                onEachFeature={(feature, layer) => {
                                    if (feature.properties && feature.properties.NAME_1) {
                                        layer.bindTooltip(feature.properties.NAME_1, {
                                            permanent: false,
                                            direction: 'auto',
                                        });
                                    }
                                }}
                            />
                        )}
                        {gpsPoints.map((point) => (
                            <Marker key={point.id} position={[point.lat, point.lng]}>
                                <Popup>
                                    <div className="min-w-[200px]">
                                        <h3 className="font-bold text-lg mb-2">{point.name}</h3>
                                        <p>
                                            <strong>Value:</strong> {point.value}
                                        </p>
                                        <p>
                                            <strong>Year:</strong> {point.year}
                                        </p>
                                        <p>
                                            <strong>Project:</strong> {selectedProject?.label}
                                        </p>
                                        <p>
                                            <strong>Intervention:</strong> {selectedIntervention?.label}
                                        </p>
                                        <p>
                                            <strong>Coordinates:</strong> {point.lat.toFixed(4)},{' '}
                                            {point.lng.toFixed(4)}
                                        </p>
                                    </div>
                                </Popup>
                            </Marker>
                        ))}
                    </MapContainer>
                </ShowInFullScreen>
            </div>

            {/* Charts Panel */}
            <div className="w-full md:w-1/5 flex-none min-h-0 flex flex-col overflow-y-auto px-4 mb-6">
                <h2 className="text-lg font-bold mb-2 text-blue-700">Selected Indicator Charts</h2>
                <ShowInFullScreen
                    title={selectedIndicator ? selectedIndicator.label : 'Indicator Chart'}
                    subtitle={`Chart showing ${selectedIndicator ? selectedIndicator.label.toLowerCase() : 'selected indicator'
                        } data`}
                    source="Data Source: Afghanistan Statistical Yearbook 2023"
                    lastUpdate="Jan 2023"
                >
                    <ResponsiveContainer width="100%" height={180}>
                        <BarChart
                            data={chartData[selectedIndicator?.value] || []}
                            margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
                        >
                            <XAxis dataKey="province" tick={{ fontSize: 10 }} />
                            <YAxis tick={{ fontSize: 10 }} />
                            <Tooltip />
                            <Bar dataKey="value" fill="#2563eb" name={selectedIndicator?.label} />
                        </BarChart>
                    </ResponsiveContainer>
                </ShowInFullScreen>
            </div>
        </div>
    );
}

export default Intervention;