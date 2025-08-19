// src/shared/MuiChartSwitcher.jsx
import React, { useMemo } from "react";
import { Box, Typography } from "@mui/material";
import {
  BarChart,
  LineChart,
  PieChart,
  ChartContainer,
  BarPlot,
  LinePlot,
  ChartsXAxis,
  ChartsYAxis,
  ChartsTooltip,
  ChartsLegend,
} from "@mui/x-charts";
import { useChartsDefaults } from "../shared/ChartsThemeProvider";

/* ---------------- built-in 10-color palettes ---------------- */
const TABLEAU10 = [
  "#4E79A7",
  "#F28E2B",
  "#E15759",
  "#76B7B2",
  "#59A14F",
  "#EDC949",
  "#AF7AA1",
  "#FF9DA7",
  "#9C755F",
  "#BAB0AC",
];
const MATERIAL10 = [
  "#1E88E5",
  "#43A047",
  "#FB8C00",
  "#8E24AA",
  "#E53935",
  "#00ACC1",
  "#7CB342",
  "#FDD835",
  "#6D4C41",
  "#3949AB",
];
const CB_SAFE10 = [
  "#000000",
  "#E69F00",
  "#56B4E9",
  "#009E73",
  "#F0E442",
  "#0072B2",
  "#D55E00",
  "#CC79A7",
  "#999999",
  "#333333",
];
const DEFAULT_10 = TABLEAU10;
const PALETTES = {
  tableau10: TABLEAU10,
  material10: MATERIAL10,
  cbSafe10: CB_SAFE10,
};

/* ---------------- helpers ---------------- */
const autoColors = (n) =>
  Array.from(
    { length: n },
    (_, i) => `hsl(${Math.floor((360 / n) * i)} 70% 50%)`
  );

const pickBasePalette = (explicit, themed, paletteName) => {
  if (explicit?.length) return explicit;
  if (themed?.length) return themed;
  if (paletteName && PALETTES[paletteName]) return PALETTES[paletteName];
  return DEFAULT_10;
};

const buildPalette = (n, base) =>
  base?.length
    ? Array.from({ length: n }, (_, i) => base[i % base.length])
    : autoColors(n);

const multiLabel = (row, levels = [], sep = " / ") =>
  levels?.length
    ? levels.map((k) => row?.[k]).join(sep)
    : row?.label ?? row?.name ?? "";

const shouldRotate = (count, force, threshold = 8) => {
  if (force === true) return true;
  if (force === false) return false;
  return count > threshold;
};

const pct = (v, total) => (total > 0 ? (v / total) * 100 : 0);
const pctText = (n, fp = 1) => `${Number.isFinite(n) ? n.toFixed(fp) : "0.0"}%`;

const extractValAndIndex = (args) => {
  if (typeof args[0] === "number" || typeof args[0] === "string") {
    const value = Number(args[0]);
    const ctx = args[1] || {};
    const dataIndex = ctx.dataIndex ?? ctx.index ?? 0;
    return { value, dataIndex, ctx };
  }
  const obj = args[0] || {};
  return {
    value: Number(obj.value ?? 0),
    dataIndex: obj.dataIndex ?? obj.index ?? 0,
    ctx: obj,
  };
};

export default function MuiChartSwitcher(props) {
  const defaults = useChartsDefaults();

  const {
    type = "bar",
    data = [],
    xKey,
    xLevels = [],
    yKeys = [],
    series = [],
    stacked = false,
    percent = false,

    // line change arrows
    lineChange = null, // 'pct' | 'delta' | null
    lineChangeBase = "prev", // 'prev' | 'first'
    showChangeArrows = true,
    linePctDecimals = 1, // NEW: control decimals for pct change

    height = 340,
    title,

    // palettes
    paletteName = "tableau10",
    colors,

    // chart behavior
    showGrid = defaults.showGrid ?? true,
    showTooltip = defaults.showTooltip ?? true,
    legendPosition = defaults.legendPosition ?? {
      vertical: "top",
      horizontal: "right",
    },
    rotateXLabels = "auto",

    // formatters/domains
    xFormatter,
    valueFormatter,
    yFormatter,
    xDomain,
    yDomain,

    // visuals
    barSize,
    lineWidth = 2,

    // bar labels
    dataLabels = false,
    barLabel,
    barLabelMode = "percent", // 'percent' | 'value' | 'both'

    // pie
    pieLabelMode = "both", // 'none' | 'percent' | 'value' | 'both'
    pieDecimals = 1,

    // optional custom axes for composed
    xAxes,
    yAxes,
  } = props;

  const vf = typeof valueFormatter === "function" ? valueFormatter : undefined;
  const yf = typeof yFormatter === "function" ? yFormatter : undefined;
  const xf = typeof xFormatter === "function" ? xFormatter : undefined;

  const basePalette = pickBasePalette(colors, defaults?.colors, paletteName);

  const normalized = useMemo(() => {
    const baseList = series?.length
      ? series
      : (yKeys || []).map((k) => ({ dataKey: k, label: k }));
    return baseList.map((s) => {
      const copy = { ...s };
      if (
        "valueFormatter" in copy &&
        typeof copy.valueFormatter !== "function"
      ) {
        delete copy.valueFormatter;
      }
      return copy;
    });
  }, [series, yKeys]);

  const palette = useMemo(
    () => buildPalette(normalized.length || data.length, basePalette),
    [normalized.length, data.length, basePalette]
  );

  const needsCompositeX = (xLevels?.length ?? 0) > 0;
  const effectiveXKey = needsCompositeX ? "__xcat__" : xKey;

  const baseDataset = useMemo(() => {
    if (!needsCompositeX) return data;
    return data.map((d) => ({ ...d, [effectiveXKey]: multiLabel(d, xLevels) }));
  }, [data, needsCompositeX, xLevels, effectiveXKey]);

  const categories = useMemo(() => {
    if (needsCompositeX) return baseDataset.map((d) => d[effectiveXKey]);
    if (xKey) return baseDataset.map((d) => d?.[xKey]);
    return baseDataset.map((_, i) => String(i + 1));
  }, [baseDataset, needsCompositeX, xKey, effectiveXKey]);

  const rotate = shouldRotate(
    categories.length,
    rotateXLabels,
    typeof defaults.rotateThreshold === "number" ? defaults.rotateThreshold : 8
  );
  const tickLabelStyle = rotate ? { angle: -90, textAnchor: "end" } : undefined;

  const legendSlotProps = {
    legend: {
      direction: "row",
      position: {
        vertical: legendPosition?.vertical ?? "top",
        horizontal: legendPosition?.horizontal ?? "right",
      },
      padding: 0,
    },
  };

  const margin = {
    top: defaults?.margin?.top ?? 30,
    right: defaults?.margin?.right ?? 30,
    bottom: defaults?.margin?.bottom ?? (rotate ? 70 : 30),
    left: defaults?.margin?.left ?? 60,
  };

  const grid = showGrid ? {} : { disableYGrid: true, disableXGrid: true };
  const tooltipSlotProps = showTooltip ? {} : { tooltip: { trigger: "none" } };

  const colorFor = (key, fallback) => {
    const map = defaults?.colorMap || {};
    return map[key] || fallback;
  };

  const toMuiSeries = (s, i) => {
    const label = s.label ?? s.dataKey;
    const base = {
      dataKey: s.dataKey,
      label,
      color: colorFor(label, s.color ?? palette[i]),
    };
    const seriesVF =
      typeof s.valueFormatter === "function" ? s.valueFormatter : vf;
    if (seriesVF) base.valueFormatter = seriesVF;

    if ((s.type ?? (type === "bar" ? "bar" : "line")) === "bar") {
      if (stacked || s.stack)
        base.stack = typeof s.stack === "string" ? s.stack : "stack-0";
      if (barSize) base.barSize = barSize;
    }
    if ((s.type ?? (type === "line" ? "line" : "bar")) === "line") {
      base.curve = s.curve ?? "linear";
      base.showMark = s.showPoints ?? true; // dots by default
      base.strokeWidth = lineWidth;
      if (s.yAxisKey) base.yAxisKey = s.yAxisKey;
    }
    if ((s.type ?? (type === "area" ? "area" : "bar")) === "area") {
      base.curve = s.curve ?? "linear";
      base.area = true;
      base.showMark = s.showPoints ?? true; // dots by default
      base.strokeWidth = lineWidth;
      base.areaOpacity = s.areaOpacity ?? 0.25;
      if (s.yAxisKey) base.yAxisKey = s.yAxisKey;
    }
    return base;
  };

  const muiSeries = normalized.map(toMuiSeries);

  const percentDataset = useMemo(() => {
    if (!percent || muiSeries.length === 0 || type !== "bar")
      return baseDataset;
    const keys = muiSeries.map((s) => s.dataKey);
    return baseDataset.map((row) => {
      const sum = keys.reduce((acc, k) => acc + Number(row?.[k] ?? 0), 0) || 1;
      const out = { ...row };
      keys.forEach((k) => (out[k] = (Number(row?.[k] ?? 0) / sum) * 100));
      return out;
    });
  }, [percent, muiSeries, type, baseDataset]);

  const buildRowTotals = (ds, keys) =>
    ds.map((row) => keys.reduce((acc, k) => acc + Number(row?.[k] ?? 0), 0));

  const decorateBarSeries = (
    seriesIn,
    ds,
    keys,
    isPercentMode,
    showLabels,
    mode
  ) => {
    const totals = buildRowTotals(ds, keys);
    const leftText = (baseVF, v, ctx) => (baseVF ? baseVF(v, ctx) : v);

    const withVF = seriesIn.map((s) => {
      const baseVF =
        typeof s.valueFormatter === "function" ? s.valueFormatter : vf;
      return {
        ...s,
        valueFormatter: (...args) => {
          const { value, dataIndex, ctx } = extractValAndIndex(args);
          const total = totals[dataIndex] ?? 0;
          const p = isPercentMode ? Number(value) : pct(Number(value), total);
          const left = leftText(baseVF, value, ctx);
          if (mode === "value") return `${left}`;
          if (mode === "both") return `${left} (${pctText(p)})`;
          return `${pctText(p)}`;
        },
      };
    });

    const autoBarLabel =
      typeof barLabel === "function"
        ? barLabel
        : showLabels
        ? (...args) => {
            const { value, dataIndex, ctx } = extractValAndIndex(args);
            const total = totals[dataIndex] ?? 0;
            const p = isPercentMode ? Number(value) : pct(Number(value), total);
            const baseVF = vf;
            const valText = leftText(baseVF, value, ctx);
            if (mode === "value") return `${valText}`;
            if (mode === "both") return `${valText} (${pctText(p, 0)})`;
            return pctText(p, 0);
          }
        : undefined;

    return { series: withVF, barLabel: barLabel ?? autoBarLabel };
  };

  // Shows CURRENT VALUE + colored change (pct with % sign, or delta)
  const decorateLineSeries = (
    seriesIn,
    ds,
    { mode = lineChange, base = lineChangeBase, show = showChangeArrows } = {}
  ) =>
    seriesIn.map((s) => {
      const key = s.dataKey;
      const baseVF =
        typeof s.valueFormatter === "function" ? s.valueFormatter : vf;

      return {
        ...s,
        valueFormatter: (v, ctx) => {
          const i = ctx?.dataIndex ?? ctx?.index ?? 0;
          const curr = Number(ds?.[i]?.[key] ?? 0);
          const currText = baseVF ? baseVF(curr, ctx) : curr;

          if (!mode || !show) return String(currText);

          // reference value (prev or first)
          const ref =
            base === "prev"
              ? i === 0
                ? 0
                : Number(ds?.[i - 1]?.[key] ?? 0)
              : Number(ds?.[0]?.[key] ?? 0);

          const deltaAbs = curr - ref;
          const sign = deltaAbs > 0 ? "▲" : deltaAbs < 0 ? "▼" : "–";
          const color = deltaAbs < 0 ? "red" : deltaAbs > 0 ? "green" : "gray";

          let changeText;
          if (mode === "pct") {
            const pctVal = ref === 0 ? 0 : (deltaAbs / Math.abs(ref)) * 100;
            // force % symbol with configurable decimals
            changeText = `${
              Number.isFinite(pctVal) ? pctVal.toFixed(linePctDecimals) : "0.0"
            }%`;
          } else {
            changeText = baseVF ? baseVF(deltaAbs, ctx) : deltaAbs;
          }

          return (
            <span>
              <strong>{currText}</strong>
              {" · "}
              <span style={{ color }}>
                {sign} {changeText}
              </span>
            </span>
          );
        },
      };
    });

  const Title = title ? (
    <Typography variant="h6" sx={{ mb: 1, textAlign: "center" }}>
      {title}
    </Typography>
  ) : null;

  /* ---------------- PIE ---------------- */
  if (type === "pie") {
    const yKeyForPie = muiSeries?.[0]?.dataKey ?? yKeys?.[0];
    const pieRows = baseDataset.map((d, idx) => {
      const lbl = needsCompositeX
        ? d[effectiveXKey]
        : xKey
        ? d?.[xKey]
        : d?.label ?? `Item ${idx + 1}`;
      const val = d?.value ?? (yKeyForPie ? d?.[yKeyForPie] : undefined);
      const text = xf ? xf(lbl) : lbl;
      return {
        id: idx,
        label: text,
        value: Number(val ?? 0),
        color: palette[idx],
      };
    });
    const total = pieRows.reduce((acc, r) => acc + (r.value || 0), 0);

    const arcText = (value) => {
      const p = pctText(pct(value, total), pieDecimals);
      if (pieLabelMode === "none") return "";
      if (pieLabelMode === "percent") return p;
      if (pieLabelMode === "value") return `${value}`;
      return `${p} • ${value}`;
    };

    return (
      <Box sx={{ width: "100%" }}>
        {Title}
        <PieChart
          series={[
            {
              data: pieRows,
              arcLabel: (item) => arcText(item.value),
              valueFormatter: (item) => {
                const p = pctText(pct(item.value, total), pieDecimals);
                if (pieLabelMode === "percent") return `${item.label}: ${p}`;
                if (pieLabelMode === "value")
                  return `${item.label}: ${item.value}`;
                if (pieLabelMode === "none")
                  return `${item.label}: ${item.value}`;
                return `${item.label}: ${item.value} (${p})`;
              },
            },
          ]}
          height={height}
          margin={margin}
          slotProps={{ ...legendSlotProps, ...tooltipSlotProps }}
          {...grid}
        />
      </Box>
    );
  }

  /* ---------------- LINE / AREA ---------------- */
  if (type === "line" || type === "area") {
    const lineSeries = decorateLineSeries(
      muiSeries.map((s) =>
        type === "area"
          ? { ...s, type: "line", area: true }
          : { ...s, type: "line" }
      ),
      baseDataset
    );
    return (
      <Box sx={{ width: "100%" }}>
        {Title}
        <LineChart
          dataset={baseDataset}
          xAxis={[
            {
              dataKey: effectiveXKey,
              scaleType: "point",
              valueFormatter: (v) => (xf ? xf(v) : v),
              tickLabelStyle,
              domain: xDomain,
            },
          ]}
          yAxis={[{ valueFormatter: yf, domain: yDomain }]}
          series={lineSeries}
          height={height}
          margin={margin}
          slotProps={{ ...legendSlotProps, ...tooltipSlotProps }}
          {...grid}
        />
      </Box>
    );
  }

  /* ---------------- COMPOSED (overlay) ---------------- */
  if (type === "composed") {
    const barSeriesOnly = muiSeries
      .map((s, i) => ({ s, i, t: normalized[i].type ?? "bar" }))
      .filter((x) => x.t === "bar")
      .map(({ s }) => s);

    const lineSeriesOnly = muiSeries
      .map((s, i) => ({ s, i, t: normalized[i].type ?? "bar" }))
      .filter((x) => x.t === "line")
      .map(({ s }) => s);

    const areaSeriesOnly = muiSeries
      .map((s, i) => ({ s, i, t: normalized[i].type ?? "bar" }))
      .filter((x) => x.t === "area")
      .map(({ s }) => ({
        ...s,
        area: true,
        areaOpacity: s.areaOpacity ?? 0.25,
      }));

    const barDS = percent ? percentDataset : baseDataset;
    const barKeys = barSeriesOnly.map((s) => s.dataKey);

    const { series: barSeriesDecorated, barLabel: barPctLabel } =
      decorateBarSeries(
        barSeriesOnly,
        barDS,
        barKeys,
        !!percent,
        !!dataLabels,
        barLabelMode
      );

    const lineSeriesDecorated = decorateLineSeries(
      [...lineSeriesOnly, ...areaSeriesOnly].map((s) => ({
        ...s,
        type: "line",
      })),
      baseDataset // original for correct MoM deltas
    );

    const combinedSeries = [
      ...barSeriesDecorated.map((s) => ({ ...s, type: "bar" })),
      ...lineSeriesDecorated.map((s) => ({ ...s, type: "line" })),
    ];

    const combinedTooltip = { ...legendSlotProps, ...tooltipSlotProps };

    const defaultXAxis = [
      {
        dataKey: effectiveXKey,
        scaleType: "band",
        valueFormatter: (v) => (xf ? xf(v) : v),
        tickLabelStyle,
        domain: xDomain,
      },
    ];

    const defaultYAxis = [
      { valueFormatter: yf, domain: percent ? [0, 100] : yDomain },
    ];

    return (
      <Box sx={{ width: "100%" }}>
        {Title}
        <ChartContainer
          dataset={barDS}
          series={combinedSeries}
          height={height}
          margin={margin}
          slotProps={combinedTooltip}
          xAxis={Array.isArray(xAxes) && xAxes.length ? xAxes : defaultXAxis}
          yAxis={Array.isArray(yAxes) && yAxes.length ? yAxes : defaultYAxis}
          // axisHighlight={{ x: "band", y: "line" }} // optional crosshair
          {...grid}
        >
          <ChartsXAxis />
          <ChartsYAxis />
          <ChartsLegend />
          <ChartsTooltip />
          <BarPlot barLabel={barPctLabel} />
          <LinePlot />
        </ChartContainer>
      </Box>
    );
  }

  /* ---------------- DEFAULT: BAR ---------------- */
  const barOnlyDS = percent ? percentDataset : baseDataset;
  const barOnlyKeys = muiSeries.map((s) => s.dataKey);
  const { series: barOnlyDecorated, barLabel: barOnlyPctLabel } =
    decorateBarSeries(
      muiSeries,
      barOnlyDS,
      barOnlyKeys,
      !!percent,
      !!dataLabels,
      barLabelMode
    );

  return (
    <Box sx={{ width: "100%" }}>
      {Title}
      <BarChart
        dataset={barOnlyDS}
        xAxis={[
          {
            dataKey: effectiveXKey,
            scaleType: "band",
            valueFormatter: (v) => (xf ? xf(v) : v),
            tickLabelStyle,
            domain: xDomain,
          },
        ]}
        yAxis={[{ valueFormatter: yf, domain: percent ? [0, 100] : yDomain }]}
        series={barOnlyDecorated}
        height={height}
        margin={margin}
        slotProps={{ ...legendSlotProps, ...tooltipSlotProps }}
        {...grid}
        barLabel={barOnlyPctLabel}
      />
    </Box>
  );
}
