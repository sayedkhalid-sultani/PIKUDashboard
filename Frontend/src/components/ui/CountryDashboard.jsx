import { useState } from "react";
import Map from "./map";
import CountryDashboardDataTable from "./CountryDashboardDataTable";
import TwoIndicators from "./TwoIndicators";
import SingleIndicator from './SingleIndicator';

const tabs = [
    { name: "Map", key: "map-tab-unique" },
    { name: "Data", key: "data-tab-unique" },
    { name: "Analyze", key: "analyze-tab-unique" },
];

export default function CountryDashboard() {
    const [activeTab, setActiveTab] = useState("map-tab-unique");
    const [prevTab, setPrevTab] = useState("map-tab-unique");
    const [animating, setAnimating] = useState(false);

    const handleTabChange = (key) => {
        if (key !== activeTab) {
            setPrevTab(activeTab);
            setAnimating(true);
            setTimeout(() => {
                setActiveTab(key);
                setAnimating(false);
            }, 350); // Duration matches Tailwind's duration-300
        }
    };

    // State for sub-tabs under "Analyze"
    const [analyzeTab, setAnalyzeTab] = useState("two-indicators-tab-unique");

    // Sub-tabs for Analyze
    const analyzeTabs = [
        { name: "Two Indicators", key: "two-indicators-tab-unique" },
        { name: "Single Indicator", key: "single-indicator-tab-unique" },
    ];

    return (
        <div className="bg-white rounded-lg shadow h-screen flex flex-col">
            {/* Top horizontal tabs */}
            <div className="flex border-b border-gray-200 bg-gray-50">
                {tabs.map((tab) => (
                    <button
                        key={tab.key}
                        onClick={() => handleTabChange(tab.key)}
                        className={`px-6 py-3 font-semibold transition-all duration-300 border-b-2 ${activeTab === tab.key
                            ? "border-blue-600 text-blue-700 bg-blue-50 scale-105"
                            : "border-transparent text-gray-500 hover:text-blue-600 hover:bg-blue-100"
                            } focus:outline-none`}
                        aria-current={activeTab === tab.key ? "page" : undefined}
                    >
                        {tab.name}
                    </button>
                ))}
            </div>

            {/* Tab Content with swap animation */}
            <div className="w-full flex-1 relative overflow-hidden p-4">
                {/* Previous tab content animates out */}
                {animating && (
                    <div
                        key={prevTab}
                        className="absolute inset-0 transition-all duration-300 ease-in-out opacity-0 translate-x-12 pointer-events-none"
                    >
                        {prevTab === "map-tab-unique" && <Map />}
                        {prevTab === "data-tab-unique" && <CountryDashboardDataTable />}
                        {prevTab === "analyze-tab-unique" && (
                            <TwoIndicators />
                        )}
                    </div>
                )}
                <div
                    key={activeTab}
                    className={`absolute inset-0 transition-all duration-300 ease-in-out ${animating ? "opacity-0 -translate-x-12" : "opacity-100 translate-x-0"}`}
                >
                    {activeTab === "map-tab-unique" && <Map />}
                    {activeTab === "data-tab-unique" && <CountryDashboardDataTable />}
                    {activeTab === "analyze-tab-unique" && (
                        <div className="h-full flex flex-col">
                            {/* Sub-tabs for Analyze */}
                            <div className="flex border-b border-gray-200 bg-gray-50 mb-4">
                                {analyzeTabs.map((tab) => (
                                    <button
                                        key={tab.key}
                                        onClick={() => setAnalyzeTab(tab.key)}
                                        className={`px-4 py-2 font-medium transition-all duration-200 border-b-2 ${analyzeTab === tab.key
                                            ? "border-blue-500 text-blue-700 bg-blue-50"
                                            : "border-transparent text-gray-500 hover:text-blue-600 hover:bg-blue-100"
                                            } focus:outline-none`}
                                    >
                                        {tab.name}
                                    </button>
                                ))}
                            </div>
                            <div className="flex-1">
                                {analyzeTab === "two-indicators-tab-unique" && <TwoIndicators />}
                                {analyzeTab === "single-indicator-tab-unique" && <SingleIndicator />}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
