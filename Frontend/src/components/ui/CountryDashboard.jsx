import { useState, useEffect } from "react";
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
    // State for sub-tabs under "Analyze"
    const [analyzeTab, setAnalyzeTab] = useState("single-indicator-tab-unique");

    // Sub-tabs for Analyze
    const analyzeTabs = [
        { name: "Single Indicator", key: "single-indicator-tab-unique" },
        { name: "Two Indicators", key: "two-indicators-tab-unique" },
    ];

    // Store the active tab in localStorage to persist across renders
    useEffect(() => {
        const savedTab = localStorage.getItem('activeTab');
        if (savedTab) {
            setActiveTab(savedTab);
        }

        const savedAnalyzeTab = localStorage.getItem('analyzeTab');
        if (savedAnalyzeTab) {
            setAnalyzeTab(savedAnalyzeTab);
        }
    }, []);

    const handleTabChange = (tabKey) => {
        setActiveTab(tabKey);
        localStorage.setItem('activeTab', tabKey);
    };

    const handleAnalyzeTabChange = (tabKey) => {
        setAnalyzeTab(tabKey);
        localStorage.setItem('analyzeTab', tabKey);
    };

    return (
        <div className="bg-white shadow flex flex-col h-screen overflow-hidden">
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

            {/* Tab Content */}
            <div className="w-full flex-1 overflow-hidden">
                {activeTab === "map-tab-unique" && <Map />}
                {activeTab === "data-tab-unique" && <CountryDashboardDataTable />}
                {activeTab === "analyze-tab-unique" && (
                    <>
                        {/* Sub-tabs for Analyze - Always visible when Analyze tab is active */}
                        <div className="flex border-b border-gray-200 bg-gray-50">
                            {analyzeTabs.map((tab) => (
                                <button
                                    key={tab.key}
                                    onClick={() => handleAnalyzeTabChange(tab.key)}
                                    className={`px-4 py-2 font-medium transition-all duration-200 border-b-2 ${analyzeTab === tab.key
                                        ? "border-blue-500 text-blue-700 bg-blue-50"
                                        : "border-transparent text-gray-500 hover:text-blue-600 hover:bg-blue-100"
                                        } focus:outline-none`}
                                >
                                    {tab.name}
                                </button>
                            ))}
                        </div>
                        <div className="flex-1 overflow-hidden" style={{ height: '100%' }}>
                            {analyzeTab === "single-indicator-tab-unique" && <SingleIndicator />}
                            {analyzeTab === "two-indicators-tab-unique" && <TwoIndicators />}
                        </div>
                    </>
                )}
            </div>
        </div>
    );
}