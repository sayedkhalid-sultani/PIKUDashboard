import React from "react";
import DataTable from "react-data-table-component";

const dummyData = [
    { id: 1, province: "Kabul", population: 5000000, literacy: 85, gdp: 2.1 },
    { id: 2, province: "Herat", population: 1800000, literacy: 78, gdp: 1.8 },
    { id: 3, province: "Balkh", population: 1500000, literacy: 75, gdp: 1.2 },
    { id: 4, province: "Kandahar", population: 1200000, literacy: 68, gdp: 1.0 },
    { id: 5, province: "Nangarhar", population: 1100000, literacy: 65, gdp: 0.9 },
    { id: 6, province: "Kunduz", population: 900000, literacy: 62, gdp: 0.8 },
    { id: 7, province: "Parwan", population: 850000, literacy: 70, gdp: 0.7 },
    { id: 8, province: "Ghazni", population: 800000, literacy: 60, gdp: 0.6 }
];

const columns = [
    {
        name: "Province",
        selector: row => row.province,
        sortable: true,
        cell: row => <span className="font-semibold text-blue-700">{row.province}</span>
    },
    {
        name: "Population",
        selector: row => row.population,
        sortable: true,
        right: true,
        cell: row => <span>{row.population.toLocaleString()}</span>
    },
    {
        name: "Literacy (%)",
        selector: row => row.literacy,
        sortable: true,
        right: true,
        cell: row => <span>{row.literacy}%</span>
    },
    {
        name: "GDP (Billion $)",
        selector: row => row.gdp,
        sortable: true,
        right: true,
        cell: row => <span>{row.gdp}</span>
    }
];

const customStyles = {
    table: {
        style: {
            borderRadius: "0.75rem",
            overflow: "hidden",
            boxShadow: "0 2px 8px 0 rgba(30,41,59,0.08)"
        }
    },
    headRow: {
        style: {
            backgroundColor: "#f1f5f9",
            fontWeight: "bold",
            fontSize: "1rem"
        }
    },
    rows: {
        style: {
            fontSize: "1rem",
            backgroundColor: "#fff",
            transition: "background 0.2s",
            minHeight: "48px"
        },
        highlightOnHoverStyle: {
            backgroundColor: "#e0e7ff",
            borderBottomColor: "#6366f1",
            outline: "none"
        }
    },
    pagination: {
        style: {
            borderTop: "1px solid #e5e7eb",
            backgroundColor: "#f9fafb"
        }
    }
};

function CountryDashboardDataTable() {
    return (
        <div className="bg-white rounded-lg shadow p-6 w-full  mx-auto">
            <h2 className="text-xl font-bold text-blue-700 mb-4">Province Data Table</h2>
            <DataTable
                columns={columns}
                data={dummyData}
                pagination
                highlightOnHover
                striped
                customStyles={customStyles}
                responsive
            />
        </div>
    );
}

export default CountryDashboardDataTable;