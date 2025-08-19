// src/pages/CountryProfilemui.jsx
import React from "react";
import { Grid, Paper, Box } from "@mui/material";
import MuiChartSwitcher from "../shared/MuiChartSwitcher";

export default function CountryProfilemui() {
  /* -------- sample datasets -------- */
  const bars = [
    { year: 2024, month: "Jan", hydro: 120, solar: 40, total: 160 },
    { year: 2024, month: "Feb", hydro: 140, solar: 45, total: 185 },
    { year: 2024, month: "Mar", hydro: 110, solar: 50, total: 160 },
    { year: 2025, month: "Jan", hydro: 150, solar: 60, total: 210 },
    { year: 2025, month: "Feb", hydro: 160, solar: 62, total: 222 },
    { year: 2025, month: "Mar", hydro: 155, solar: 64, total: 219 },
  ];

  const stacked = [
    { year: 2024, month: "Jan", diesel: 30, gas: 70, coal: 40, demand: 150 },
    { year: 2024, month: "Feb", diesel: 25, gas: 80, coal: 38, demand: 160 },
    { year: 2024, month: "Mar", diesel: 28, gas: 75, coal: 35, demand: 158 },
    { year: 2025, month: "Jan", diesel: 32, gas: 82, coal: 30, demand: 170 },
    { year: 2025, month: "Feb", diesel: 29, gas: 86, coal: 28, demand: 176 },
    { year: 2025, month: "Mar", diesel: 27, gas: 90, coal: 25, demand: 175 },
  ];

  const stackedPct = [
    { year: 2024, quarter: "Q1", hr: 40, it: 30, sales: 30, headcount: 120 },
    { year: 2024, quarter: "Q2", hr: 35, it: 25, sales: 40, headcount: 130 },
    { year: 2024, quarter: "Q3", hr: 30, it: 40, sales: 30, headcount: 128 },
    { year: 2025, quarter: "Q1", hr: 28, it: 42, sales: 30, headcount: 135 },
    { year: 2025, quarter: "Q2", hr: 32, it: 38, sales: 30, headcount: 138 },
    { year: 2025, quarter: "Q3", hr: 33, it: 37, sales: 30, headcount: 140 },
  ];

  // Simple pie: provide { label, value } rows (or use xKey/yKey variant)
  const energySharePie = [
    { label: "Hydro", value: 120 },
    { label: "Solar", value: 80 },
    { label: "Wind", value: 60 },
    { label: "Thermal", value: 40 },
  ];

  // Dual-axis example: bars (MW) + line (%) on right axis
  const genUtil = [
    { y: 2024, m: "Jan", hydro: 120, solar: 40, util: 74 },
    { y: 2024, m: "Feb", hydro: 140, solar: 45, util: 78 },
    { y: 2024, m: "Mar", hydro: 110, solar: 50, util: 71 },
    { y: 2025, m: "Jan", hydro: 150, solar: 60, util: 80 },
    { y: 2025, m: "Feb", hydro: 160, solar: 62, util: 82 },
    { y: 2025, m: "Mar", hydro: 155, solar: 64, util: 79 },
  ];

  return (
    <Box sx={{ p: 2 }}>
      <Grid container spacing={2}>
        {/* ===== Bars only ===== */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="bar"
              title="Electricity Output by Year / Month"
              data={bars}
              xKey="month"
              xLevels={["year", "month"]}
              yKeys={["hydro", "solar"]}
              showGrid
              dataLabels
              barLabelMode="value"
            />
          </Paper>
        </Grid>

        {/* ===== Stacked bars ===== */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="bar"
              title="Fuel Mix by Year / Month (Stacked)"
              data={stacked}
              xKey="month"
              xLevels={["year", "month"]}
              stacked
              yKeys={["diesel", "gas", "coal"]}
              dataLabels
              barLabelMode="value"
            />
          </Paper>
        </Grid>

        {/* ===== 100% stacked bars ===== */}
        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="bar"
              title="Department Share by Quarter (100% Stacked)"
              data={stackedPct}
              xKey="quarter"
              xLevels={["year", "quarter"]}
              yKeys={["hr", "it", "sales"]}
              stacked
              percent
              yFormatter={(v) => `${v.toFixed(0)}%`}
              dataLabels
              barLabelMode="percent"
            />
          </Paper>
        </Grid>

        {/* ===== Composed: bars + line overlay (same axis) ===== */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="composed"
              title="Hydro & Solar with Total (Overlay)"
              data={bars}
              xKey="month"
              xLevels={["year", "month"]}
              series={[
                { dataKey: "hydro", label: "Hydro", type: "bar" },
                { dataKey: "solar", label: "Solar", type: "bar" },
                {
                  dataKey: "total",
                  label: "Total",
                  type: "line",
                  showPoints: true,
                },
              ]}
              dataLabels
              barLabelMode="value"
            />
          </Paper>
        </Grid>

        {/* ===== Composed: stacked bars + line with MoM colored arrows ===== */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="composed"
              title="Fuel Mix (Stacked) + Demand (Line with MoM ▲▼)"
              data={stacked}
              xKey="month"
              xLevels={["year", "month"]}
              stacked
              series={[
                { dataKey: "diesel", label: "Diesel", type: "bar" },
                { dataKey: "gas", label: "Gas", type: "bar" },
                { dataKey: "coal", label: "Coal", type: "bar" },
                {
                  dataKey: "demand",
                  label: "Demand",
                  type: "line",
                  showPoints: true,
                },
              ]}
              // enable colored ▲▼ computed vs previous month
              lineChange="pct" // or "delta" for absolute change
              lineChangeBase="prev"
              showChangeArrows
              dataLabels
              barLabelMode="value"
            />
          </Paper>
        </Grid>

        {/* ===== Composed: Dual-axis (bars left, line right) ===== */}
        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="composed"
              title="Generation (MW) + Utilization (%) — Dual Axis"
              data={genUtil}
              xKey="m"
              xLevels={["y", "m"]}
              series={[
                { dataKey: "hydro", label: "Hydro (MW)", type: "bar" },
                { dataKey: "solar", label: "Solar (MW)", type: "bar" },
                {
                  dataKey: "util",
                  label: "Utilization (%)",
                  type: "line",
                  yAxisKey: "right",
                  showPoints: true,
                },
              ]}
              // define both Y-axes and bind the line with yAxisKey: 'right'
              yAxes={[
                {
                  id: "left",
                  position: "left",
                  valueFormatter: (v) => `${v}`,
                  min: 0,
                  max: 200,
                },
                {
                  id: "right",
                  position: "right",
                  valueFormatter: (v) => `${v}%`,
                  min: 0,
                  max: 100,
                },
              ]}
              dataLabels
              barLabelMode="value"
            />
          </Paper>
        </Grid>

        {/* ===== Pie: both percentage + value ===== */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="pie"
              title="Energy Share — Both"
              data={energySharePie} // rows {label, value}
              pieLabelMode="both" // shows "55.0% • 120"
              pieDecimals={1}
              height={320}
            />
          </Paper>
        </Grid>

        {/* ===== Pie: percent-only labels ===== */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="pie"
              title="Energy Share — Percent Only"
              data={energySharePie}
              pieLabelMode="percent"
              pieDecimals={1}
              height={320}
            />
          </Paper>
        </Grid>

        {/* ===== Pie: no arc labels (tooltips still on) ===== */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="pie"
              title="Energy Share — No Slice Labels"
              data={energySharePie}
              pieLabelMode="none"
              height={320}
            />
          </Paper>
        </Grid>

        {/* ===== Plain line with MoM colored arrows (delta) ===== */}
        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 2 }}>
            <MuiChartSwitcher
              type="line"
              title="Total Demand — MoM Change (Δ)"
              data={stacked}
              xKey="month"
              xLevels={["year", "month"]}
              series={[
                {
                  dataKey: "demand",
                  label: "Demand",
                  type: "line",
                  showPoints: true,
                },
              ]}
              lineChange="delta" // absolute change vs previous
              lineChangeBase="prev"
              showChangeArrows
            />
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
