import { useState } from "react";
import Map from "./map";
import CountryDashboardDataTable from "./CountryDashboardDataTable";
import CountryDashboardAnalyze from "./CountryDashboardAnalyze";

const tabs = [
    { name: "Map", key: "map" },
    { name: "Data", key: "data" },
    { name: "Analyze", key: "analyze" },
];

export default function CountryDashboard() {
    const [activeTab, setActiveTab] = useState("map");
    const [prevTab, setPrevTab] = useState("map");
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

    return (
        <div className="bg-white rounded-lg shadow h-screen flex flex-col">
            {/* Top horizontal tabs */}
            <div className="flex border-b border-gray-200 bg-gray-50">
                {tabs.map((tab, idx) => (
                    <button
                        key={tab.key + idx}
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
                        {prevTab === "map" && <Map />}
                        {prevTab === "data" && <CountryDashboardDataTable />}
                        {prevTab === "analyze" && <CountryDashboardAnalyze />}
                    </div>
                )}
                <div
                    key={activeTab}
                    className={`absolute inset-0 transition-all duration-300 ease-in-out ${animating ? "opacity-0 -translate-x-12" : "opacity-100 translate-x-0"}`}
                >
                    {activeTab === "map" && <Map />}
                    {activeTab === "data" && <CountryDashboardDataTable />}
                    {activeTab === "analyze" && <CountryDashboardAnalyze />}
                </div>
            </div>
        </div>
    );
}
