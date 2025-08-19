// src/pages/CountryProfile.jsx
import React from "react";
import ChartSwitcherRecharts from "../shared/ChartSwitcherRecharts";

const CountryProfile = () => {
  // ---------- Sample Data Sources ----------
  const sources = {
    productAgg: [
      { product: "Laptop", revenue: 1900, target: 1500, returns: 200 },
      { product: "Phone", revenue: 1400, target: 1300, returns: 140 },
      { product: "Tablet", revenue: 500, target: 700, returns: 60 },
    ],
    stackedDepts: [
      { month: "Jan", hr: 500, it: 700, sales: 900 },
      { month: "Feb", hr: 450, it: 750, sales: 1000 },
      { month: "Mar", hr: 520, it: 720, sales: 1100 },
      { month: "Apr", hr: 480, it: 760, sales: 1050 },
    ],
    productShare: [
      { name: "Laptop", value: 57 },
      { name: "Phone", value: 33 },
      { name: "Tablet", value: 10 },
    ],
    categorySales: [
      { category: "Accessories", sales: 320 },
      { category: "Audio", sales: 240 },
      { category: "Gaming", sales: 410 },
      { category: "Smart Home", sales: 300 },
    ],
    trendLine: [
      { month: "Jan", value: 20 },
      { month: "Feb", value: 42 },
      { month: "Mar", value: 35 },
      { month: "Apr", value: 58 },
      { month: "May", value: 64 },
    ],
    regionStack: [
      { quarter: "Q1", north: 320, south: 210, east: 180, west: 260 },
      { quarter: "Q2", north: 340, south: 220, east: 190, west: 280 },
      { quarter: "Q3", north: 360, south: 210, east: 200, west: 290 },
      { quarter: "Q4", north: 390, south: 240, east: 220, west: 310 },
    ],
    // Multi-level samples
    geoHierarchy: [
      { region: "North", province: "Alpha", district: "A1", sales: 120 },
      { region: "North", province: "Alpha", district: "A2", sales: 160 },
      { region: "North", province: "Beta", district: "B1", sales: 90 },
      { region: "South", province: "Gamma", district: "G1", sales: 180 },
      { region: "South", province: "Gamma", district: "G2", sales: 140 },
      { region: "South", province: "Delta", district: "D1", sales: 110 },
    ],
    calendarHierarchy: [
      { year: "2025", quarter: "Q1", month: "Jan", value: 22, target: 30 },
      { year: "2025", quarter: "Q1", month: "Feb", value: 28, target: 30 },
      { year: "2025", quarter: "Q1", month: "Mar", value: 31, target: 30 },
      { year: "2025", quarter: "Q2", month: "Apr", value: 26, target: 30 },
      { year: "2025", quarter: "Q2", month: "May", value: 29, target: 30 },
      { year: "2025", quarter: "Q2", month: "Jun", value: 35, target: 30 },
    ],
  };

  // ---------- Colors ----------
  const colors = ["#2563eb", "#16a34a", "#f59e0b", "#ef4444", "#a855f7"];

  // ---------- Card style ----------
  const card = {
    background: "#fff",
    border: "1px solid #eee",
    borderRadius: 10,
    padding: 10,
    width: "100%",
  };

  return (
    <div style={{ padding: 16 }}>
      {/* GRID LAYOUT: 3 columns */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
          gap: 16,
          alignItems: "stretch",
          width: "100%",
        }}
      >
        {/* 1) Revenue vs Target */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "rev-vs-target",
                label: "Revenue vs Target",
                type: "barWithLine",
                dataSource: "productAgg",
                title: "Revenue vs Target — FY2025",
                source: "Internal Sales DB",
                updatedAt: "2025-08-15",
                xLevels: ["product"],
                bars: [
                  { key: "revenue", label: "Revenue", yAxis: "left" },
                  { key: "returns", label: "Returns", yAxis: "left" },
                ],
                lines: [{ key: "target", label: "Target", yAxis: "left" }],
                showBarValueLabels: true,
                barValueLabelColor: "#fff",
              },
            ]}
            sources={sources}
            initialChartId="rev-vs-target"
            colors={colors}
            height={340}
          />
        </div>

        {/* 2) Department Costs */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "dept-stacked",
                label: "Department Costs",
                type: "stackedBar",
                dataSource: "stackedDepts",
                title: "Monthly Department Costs",
                source: "Finance Ledger",
                updatedAt: new Date(),
                xLevels: ["month"],
                stackBars: [
                  { key: "hr", label: "HR" },
                  { key: "it", label: "IT" },
                  { key: "sales", label: "Sales" },
                ],
                showBarValueLabels: true,
                barValueLabelColor: "#fff",
              },
            ]}
            sources={sources}
            initialChartId="dept-stacked"
            colors={colors}
            height={340}
          />
        </div>

        {/* 3) Product Share */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "product-share",
                label: "Product Share",
                type: "pie",
                dataSource: "productShare",
                title: "Product Share (Units)",
                source: "Sales Mix",
                updatedAt: "2025-08-10",
                pie: {
                  nameKey: "name",
                  valueKey: "value",
                  innerRadius: 0,
                  outerRadius: 90,
                },
              },
            ]}
            sources={sources}
            initialChartId="product-share"
            colors={colors}
            height={340}
          />
        </div>

        {/* 4) Category Sales */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "category-sales",
                label: "Category Sales",
                type: "bar",
                dataSource: "categorySales",
                title: "Sales by Category",
                source: "eCommerce DB",
                updatedAt: "2025-08-12",
                xLevels: ["category"],
                bars: [{ key: "sales", label: "Sales", yAxis: "left" }],
                rotateIfTight: false,
                showBarValueLabels: true,
                barValueLabelColor: "#fff",
              },
            ]}
            sources={sources}
            initialChartId="category-sales"
            colors={colors}
            height={340}
          />
        </div>

        {/* 5) Trend Line */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "trend-line",
                label: "Monthly Trend",
                type: "line",
                dataSource: "trendLine",
                title: "Monthly Trend (Units)",
                source: "Telemetry",
                updatedAt: "2025-08-14",
                xLevels: ["month"],
                lines: [{ key: "value", label: "Value", yAxis: "left" }],
              },
            ]}
            sources={sources}
            initialChartId="trend-line"
            colors={colors}
            height={340}
          />
        </div>

        {/* 6) Regional Sales */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "region-stacked",
                label: "Regional Sales",
                type: "stackedBar",
                dataSource: "regionStack",
                title: "Regional Sales by Quarter",
                source: "CRM",
                updatedAt: "2025-08-13",
                xLevels: ["quarter"],
                stackBars: [
                  { key: "north", label: "North" },
                  { key: "south", label: "South" },
                  { key: "east", label: "East" },
                  { key: "west", label: "West" },
                ],
              },
            ]}
            sources={sources}
            initialChartId="region-stacked"
            colors={colors}
            height={340}
          />
        </div>

        {/* 7) Geo Hierarchy Sales */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "geo-multilevel",
                label: "Geo Hierarchy Sales",
                type: "bar",
                dataSource: "geoHierarchy",
                title: "Sales by Region / Province / District",
                source: "Field Ops",
                updatedAt: "2025-08-15",
                xLevels: ["region", "province", "district"],
                bars: [{ key: "sales", label: "Sales", yAxis: "left" }],
                rotateIfTight: false,
                showBarValueLabels: true,
                barValueLabelColor: "#fff",
                tickFontSize: 11,
                tickLineHeight: 12,
                tickBottomPad: 12,
              },
            ]}
            sources={sources}
            initialChartId="geo-multilevel"
            colors={colors}
            height={380}
          />
        </div>

        {/* 8) Calendar Multi-level */}
        <div style={card}>
          <ChartSwitcherRecharts
            charts={[
              {
                id: "calendar-multilevel",
                label: "Monthly Output",
                type: "barWithLine",
                dataSource: "calendarHierarchy",
                title: "Output by Month (Year / Quarter / Month)",
                source: "Ops Telemetry",
                updatedAt: "2025-08-15",
                xLevels: ["year", "quarter", "month"],
                bars: [{ key: "value", label: "Output", yAxis: "left" }],
                lines: [{ key: "target", label: "Target", yAxis: "left" }],
                rotateIfTight: true,
                showBarValueLabels: true,
                barValueLabelColor: "#fff",
                tickFontSize: 11,
                tickLineHeight: 12,
                tickBottomPad: 12,
              },
            ]}
            sources={sources}
            initialChartId="calendar-multilevel"
            colors={colors}
            height={380}
          />
        </div>
      </div>
    </div>
  );
};

export default CountryProfile;
