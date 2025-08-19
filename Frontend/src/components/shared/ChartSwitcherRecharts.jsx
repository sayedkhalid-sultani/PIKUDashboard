// src/components/shared/ChartSwitcherRecharts.jsx
import React, { useMemo, useState, useCallback } from "react";
import {
  ComposedChart,
  BarChart,
  LineChart,
  PieChart,
  Bar,
  Line,
  Pie,
  Cell,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  CartesianGrid,
  ResponsiveContainer,
  LabelList,
} from "recharts";

import MultiLevelTick from "./MultiLevelTick";

/* ---------------- shared legend + margins (APPLIES TO ALL CHARTS) ---------------- */
const legendProps = {
  layout: "horizontal",
  verticalAlign: "top",
  align: "right",
  wrapperStyle: { top: 5, right: 0, paddingBottom: 0, lineHeight: "1" },
};
// base margins; bottom is adjusted per chart to avoid clipping ticks
const baseMargin = { top: 10, right: 10, bottom: 0, left: 10 };

/* ---------------- helpers ---------------- */
const autoColors = (n) =>
  Array.from(
    { length: n },
    (_, i) => `hsl(${Math.floor((360 / n) * i)} 70% 50%)`
  );
const buildPalette = (n, colors) => (colors?.length ? colors : autoColors(n));
const multiLabel = (d, levels = [], sep = " / ") =>
  levels?.length
    ? levels.map((k) => d?.[k]).join(sep)
    : d?.label ?? d?.category ?? d?.name;

const formatDate = (d) => {
  if (!d) return "";
  try {
    return new Date(d).toLocaleDateString();
  } catch {
    return String(d);
  }
};
const fmtPct = (x) => (Number.isFinite(x) ? `${x.toFixed(1)}%` : "—");

/* ---------- single-line rotation heuristic (when NOT multi-line) ---------- */
function needRotateLabels(data = [], levels = []) {
  const labels = data.map((d) => multiLabel(d, levels) ?? "");
  const maxLen = labels.reduce((m, s) => Math.max(m, String(s).length), 0);
  const n = labels.length;
  return n >= 8 || maxLen >= 10;
}
function xAxisProps(data, levels) {
  const rotate = needRotateLabels(data, levels);
  return rotate
    ? { angle: -90, textAnchor: "end", interval: 0, height: 80, tickMargin: 8 }
    : {
        angle: 0,
        textAnchor: "middle",
        interval: "preserveEnd",
        tickMargin: 6,
      };
}

/* ---------------- tooltips ---------------- */
function StackedTooltip({ active, label, payload, hoveredKey }) {
  if (!active || !payload?.length) return null;
  const total = payload.reduce((s, p) => s + (Number(p.value) || 0), 0);
  const item = payload.find((p) => p.dataKey === hoveredKey) ?? payload[0];
  const pct = total ? ((Number(item?.value) || 0) / total) * 100 : 0;
  return (
    <div style={ttBox}>
      <div style={ttTitle}>{label}</div>
      <div style={{ ...ttRow, color: item?.color || item?.fill }}>
        {item?.name ?? item?.dataKey}:{" "}
        <b style={{ margin: "0 6px" }}>{item?.value}</b> ({fmtPct(pct)})
      </div>
    </div>
  );
}
function BarPctTooltip({ active, payload, data = [] }) {
  if (!active || !payload?.length) return null;
  const item = payload[0];
  const key = item?.dataKey;
  const val = Number(item?.value) || 0;
  const total = data.reduce((sum, d) => sum + (Number(d?.[key]) || 0), 0);
  const pct = total ? (val / total) * 100 : 0;
  const title =
    item?.payload &&
    (item.payload.label || item.payload.category || item.payload.name);
  return (
    <div style={ttBox}>
      {title && <div style={ttTitle}>{title}</div>}
      <div>
        {item?.name ?? key}: <b>{val}</b> ({fmtPct(pct)})
      </div>
    </div>
  );
}
function PieTooltip({ active, payload, data = [], valueKey = "value" }) {
  if (!active || !payload?.length) return null;
  const total = data.reduce((sum, d) => sum + (Number(d?.[valueKey]) || 0), 0);
  const item = payload[0];
  const val = Number(item?.value) || 0;
  const pct = total ? (val / total) * 100 : 0;
  return (
    <div style={ttBox}>
      <div style={ttTitle}>{item?.name}</div>
      <div>
        {val} ({fmtPct(pct)})
      </div>
    </div>
  );
}
function indexFromLabel(data = [], levels = [], label) {
  return data.findIndex((d) => multiLabel(d, levels) === label);
}
function changeVisual(changePct) {
  if (!Number.isFinite(changePct)) return { arrow: "", color: "#6b7280" };
  if (changePct > 0) return { arrow: "▲", color: "#16a34a" };
  if (changePct < 0) return { arrow: "▼", color: "#ef4444" };
  return { arrow: "•", color: "#6b7280" };
}
function LineWithChangeTooltip({
  active,
  label,
  payload,
  data = [],
  levels = [],
  lineKeys = [],
}) {
  if (!active || !payload?.length) return null;
  const idx = indexFromLabel(data, levels, label);
  const linesOnly = payload.filter((p) => lineKeys.includes(p.dataKey));
  if (!linesOnly.length) return null;
  return (
    <div style={ttBox}>
      <div style={ttTitle}>{label}</div>
      {linesOnly.map((p) => {
        const key = p.dataKey;
        const val = Number(p.value) || 0;
        const prev = idx > 0 ? Number(data[idx - 1]?.[key]) : null;
        const changePct =
          prev === null || prev === 0
            ? Number.isFinite(prev) && prev === 0
              ? Infinity
              : null
            : ((val - prev) / prev) * 100;
        const { arrow, color } = changeVisual(changePct);
        return (
          <div key={key} style={{ ...ttRow, color: p.stroke || p.color }}>
            {p.name ?? key}: <b style={{ margin: "0 6px" }}>{val}</b>
            <span style={{ color, marginLeft: 6 }}>
              {changePct === null
                ? ""
                : arrow +
                  " " +
                  (changePct === Infinity ? "∞%" : fmtPct(changePct))}
            </span>
          </div>
        );
      })}
    </div>
  );
}
function BarLineMixedTooltip({
  active,
  label,
  payload,
  data = [],
  levels = [],
  barKeys = [],
  lineKeys = [],
}) {
  if (!active || !payload?.length) return null;
  const idx = indexFromLabel(data, levels, label);
  const bars = payload.filter((p) => barKeys.includes(p.dataKey));
  const lines = payload.filter((p) => lineKeys.includes(p.dataKey));
  if (!bars.length && !lines.length) return null;
  return (
    <div style={ttBox}>
      <div style={ttTitle}>{label}</div>
      {bars.map((p) => {
        const key = p.dataKey;
        const val = Number(p.value) || 0;
        const total = data.reduce((sum, d) => sum + (Number(d?.[key]) || 0), 0);
        const pct = total ? (val / total) * 100 : 0;
        return (
          <div
            key={`bar-${key}`}
            style={{ ...ttRow, color: p.fill || p.color }}
          >
            {p.name ?? key}: <b style={{ margin: "0 6px" }}>{val}</b> (
            {fmtPct(pct)})
          </div>
        );
      })}
      {lines.map((p) => {
        const key = p.dataKey;
        const val = Number(p.value) || 0;
        const prev = idx > 0 ? Number(data[idx - 1]?.[key]) : null;
        const changePct =
          prev === null || prev === 0
            ? Number.isFinite(prev) && prev === 0
              ? Infinity
              : null
            : ((val - prev) / prev) * 100;
        const { arrow, color } = changeVisual(changePct);
        return (
          <div
            key={`line-${key}`}
            style={{ ...ttRow, color: p.stroke || p.color }}
          >
            {p.name ?? key}: <b style={{ margin: "0 6px" }}>{val}</b>
            <span style={{ color, marginLeft: 6 }}>
              {changePct === null
                ? ""
                : arrow +
                  " " +
                  (changePct === Infinity ? "∞%" : fmtPct(changePct))}
            </span>
          </div>
        );
      })}
    </div>
  );
}

/* ---------- Vertical bar value labels ---------- */
function VerticalBarValueLabel({
  x,
  y,
  width,
  height,
  value,
  color = "#fff",
  fontSize = 11,
}) {
  if (value == null) return null;
  const cx = x + width / 2;
  const cy = y + height / 2;
  if (height < 16 || width < 8) return null;
  return (
    <g transform={`rotate(-90 ${cx} ${cy})`}>
      <text
        x={cx}
        y={cy}
        textAnchor="middle"
        dominantBaseline="central"
        fill={color}
        fontSize={fontSize}
      >
        {value}
      </text>
    </g>
  );
}

/* tooltip styles (single definition to avoid redeclare errors) */
const ttBox = {
  background: "rgba(255,255,255,0.98)",
  border: "1px solid #e5e7eb",
  borderRadius: 8,
  padding: "8px 10px",
  boxShadow: "0 6px 20px rgba(0,0,0,0.08)",
  fontSize: 12,
};
const ttTitle = { fontWeight: 600, marginBottom: 0 };
const ttRow = { display: "flex", alignItems: "center" };

/* ---------- main switcher (keeps your original API) ---------- */
export default function ChartSwitcherRecharts({
  charts = [],
  sources = {},
  initialChartId,
  colors,
  height = 360,
  defaultTitle = "",
  defaultSource = "",
  defaultUpdatedAt = "",
  titleStyle = {
    fontWeight: "normal",
    fontSize: 16,
    textAlign: "center",
    margin: "4px 4px 10px",
  },
}) {
  const [chartId] = useState(initialChartId ?? charts[0]?.id);

  const active = useMemo(
    () => charts.find((c) => c.id === chartId) ?? charts[0],
    [charts, chartId]
  );
  const rows = useMemo(
    () => sources[active?.dataSource] ?? [],
    [sources, active]
  );
  const data = useMemo(
    () =>
      typeof active?.transform === "function" ? active.transform(rows) : rows,
    [active, rows]
  );

  // meta
  const chartTitle = active?.title ?? defaultTitle ?? active?.label ?? "";
  const sourceLabel = active?.source ?? defaultSource ?? "";
  const updatedText = active?.updatedAt ?? defaultUpdatedAt ?? "";
  const updatedFmt = updatedText ? formatDate(updatedText) : "";

  // series keys
  const barKeys = useMemo(
    () => (active?.bars ?? []).map((b) => b.key),
    [active]
  );
  const lineKeys = useMemo(
    () => (active?.lines ?? []).map((l) => l.key),
    [active]
  );

  // palettes
  const barCount =
    (active?.bars?.length ?? active?.stackBars?.length ?? 1) || 1;
  const lineCount = active?.lines?.length ?? 1;
  const barPalette = useMemo(
    () => buildPalette(barCount, colors),
    [barCount, colors]
  );
  const linePalette = useMemo(
    () => buildPalette(lineCount, colors?.slice?.(1)),
    [lineCount, colors]
  );

  // stacked hover
  const [hoveredStackKey, setHoveredStackKey] = useState(null);
  const onBarOver = useCallback((key) => () => setHoveredStackKey(key), []);
  const onBarOut = useCallback(() => setHoveredStackKey(null), []);

  if (!active) return null;

  // single-line props
  const xProps = useMemo(
    () => xAxisProps(data, active.xLevels || []),
    [data, active]
  );

  // multi-line?
  const xLevels = Array.isArray(active?.xLevels) ? active.xLevels : [];
  const useMultiLineTick =
    xLevels.length > 1 && active.multiLineTicks !== false;

  // leafKey for XAxis anchoring when multi-line
  const leafKey = useMemo(
    () => (useMultiLineTick ? xLevels[xLevels.length - 1] : undefined),
    [useMultiLineTick, xLevels]
  );

  // tick spacing knobs
  const tickFontSize = Number(active?.tickFontSize) || 12;
  const tickLineHeight = Number(active?.tickLineHeight) || 14;
  const tickBottomPad = Number(active?.tickBottomPad ?? 10);
  const tickTopPad = Number(active?.tickTopPad ?? 4);

  // bottom space to avoid clipping multi-line ticks
  const bottomForTicks = useMultiLineTick
    ? Math.max(
        40,
        tickBottomPad + tickLineHeight * xLevels.length + tickFontSize * 0.3
      )
    : xProps?.height || 28;

  // vertical labels
  const showBarValueLabels = !!active?.showBarValueLabels;
  const barValueLabelColor = active?.barValueLabelColor || "#fff";
  const barValueLabelFontSize = Number(active?.barValueLabelFontSize) || 11;

  // helper to render a consistent XAxis
  const renderXAxis = (fallbackLabelFn) => {
    if (useMultiLineTick && leafKey) {
      return (
        <XAxis
          dataKey={leafKey}
          interval={0}
          height={
            (MultiLevelTick.axisHeight?.(
              xLevels.length,
              tickLineHeight,
              tickBottomPad
            ) ?? tickBottomPad + tickLineHeight * xLevels.length) + tickTopPad
          }
          tick={(props) => (
            <MultiLevelTick
              {...props}
              levels={xLevels}
              leafKey={leafKey}
              rows={data}
              rotateIfTight={active.rotateIfTight !== false}
              lineHeight={tickLineHeight}
              fontSize={tickFontSize}
              itemCount={data?.length}
              topPad={tickTopPad}
            />
          )}
        />
      );
    }
    return <XAxis dataKey={fallbackLabelFn} {...xProps} />;
  };

  // compute margins for this chart (base + bottom adjustment)
  const margin = { ...baseMargin, bottom: bottomForTicks };

  return (
    <div style={{ width: "100%" }}>
      {!!chartTitle && <div style={titleStyle}>{chartTitle}</div>}

      {/* BAR */}
      {active.type === "bar" && (
        <ResponsiveContainer width="100%" height={height}>
          <BarChart data={data} margin={margin}>
            <CartesianGrid strokeDasharray="3 3" />
            {renderXAxis((d) => multiLabel(d, xLevels))}
            <YAxis yAxisId="left" />
            <Tooltip content={<BarPctTooltip data={data} />} />
            <Legend {...legendProps} />
            {(
              active.bars ?? [
                {
                  key: active.valueKey || "value",
                  label: active.label || "Value",
                },
              ]
            ).map((b, i) => (
              <Bar
                key={b.key}
                dataKey={b.key}
                name={b.label ?? b.key}
                fill={barPalette[i % barPalette.length]}
                yAxisId={b.yAxis || "left"}
              >
                {showBarValueLabels && (
                  <LabelList
                    dataKey={b.key}
                    content={(props) => (
                      <VerticalBarValueLabel
                        {...props}
                        color={barValueLabelColor}
                        fontSize={barValueLabelFontSize}
                      />
                    )}
                  />
                )}
              </Bar>
            ))}
          </BarChart>
        </ResponsiveContainer>
      )}

      {/* STACKED BAR */}
      {active.type === "stackedBar" && (
        <ResponsiveContainer width="100%" height={height}>
          <BarChart data={data} margin={margin}>
            <CartesianGrid strokeDasharray="3 3" />
            {renderXAxis((d) => multiLabel(d, xLevels))}
            <YAxis />
            <Tooltip
              content={<StackedTooltip hoveredKey={hoveredStackKey} />}
            />
            <Legend {...legendProps} />
            {(active.stackBars ?? []).map((b, i) => (
              <Bar
                key={b.key}
                dataKey={b.key}
                name={b.label ?? b.key}
                stackId="a"
                fill={barPalette[i % barPalette.length]}
                onMouseOver={onBarOver(b.key)}
                onMouseOut={onBarOut}
              >
                {showBarValueLabels && (
                  <LabelList
                    dataKey={b.key}
                    content={(props) => (
                      <VerticalBarValueLabel
                        {...props}
                        color={barValueLabelColor}
                        fontSize={barValueLabelFontSize}
                      />
                    )}
                  />
                )}
              </Bar>
            ))}
          </BarChart>
        </ResponsiveContainer>
      )}

      {/* LINE */}
      {active.type === "line" && (
        <ResponsiveContainer width="100%" height={height}>
          <LineChart data={data} margin={margin}>
            <CartesianGrid strokeDasharray="3 3" />
            {renderXAxis((d) => multiLabel(d, xLevels))}
            <YAxis />
            <Tooltip
              content={
                <LineWithChangeTooltip
                  data={data}
                  levels={xLevels || []}
                  lineKeys={lineKeys}
                />
              }
            />
            <Legend {...legendProps} />
            {(
              active.lines ?? [
                {
                  key: active.valueKey || "value",
                  label: active.label || "Value",
                },
              ]
            ).map((l, i) => (
              <Line
                key={l.key}
                type="monotone"
                dataKey={l.key}
                name={l.label ?? l.key}
                stroke={linePalette[i % linePalette.length]}
                strokeWidth={3}
                dot={{ r: 3 }}
                activeDot={{ r: 5 }}
                connectNulls
                yAxisId={l.yAxis || "left"}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      )}

      {/* BAR + LINE */}
      {active.type === "barWithLine" && (
        <ResponsiveContainer width="100%" height={height}>
          <ComposedChart data={data} margin={margin}>
            <CartesianGrid strokeDasharray="3 3" />
            {renderXAxis((d) => multiLabel(d, xLevels))}
            <YAxis yAxisId="left" />
            {((active.bars ?? []).some((b) => b.yAxis === "right") ||
              (active.lines ?? []).some((l) => l.yAxis === "right")) && (
              <YAxis yAxisId="right" orientation="right" />
            )}
            <Tooltip
              content={
                <BarLineMixedTooltip
                  data={data}
                  levels={xLevels || []}
                  barKeys={barKeys}
                  lineKeys={lineKeys}
                />
              }
            />
            <Legend {...legendProps} />
            {(active.bars ?? []).map((b, i) => (
              <Bar
                key={b.key}
                dataKey={b.key}
                name={b.label ?? b.key}
                fill={barPalette[i % barPalette.length]}
                yAxisId={b.yAxis || "left"}
              >
                {showBarValueLabels && (
                  <LabelList
                    dataKey={b.key}
                    content={(props) => (
                      <VerticalBarValueLabel
                        {...props}
                        color={barValueLabelColor}
                        fontSize={barValueLabelFontSize}
                      />
                    )}
                  />
                )}
              </Bar>
            ))}
            {(active.lines ?? []).map((l, i) => (
              <Line
                key={l.key}
                type="monotone"
                dataKey={l.key}
                name={l.label ?? l.key}
                stroke={linePalette[i % linePalette.length]}
                strokeWidth={3}
                dot={{ r: 3 }}
                activeDot={{ r: 5 }}
                connectNulls
                yAxisId={l.yAxis || "left"}
              />
            ))}
          </ComposedChart>
        </ResponsiveContainer>
      )}

      {/* PIE / DONUT */}
      {active.type === "pie" && (
        <ResponsiveContainer width="100%" height={height}>
          <PieChart margin={{ ...baseMargin, bottom: 10 }}>
            <Tooltip
              content={
                <PieTooltip
                  data={data}
                  valueKey={(active.pie || {}).valueKey || "value"}
                />
              }
            />
            <Legend {...legendProps} />
            {(() => {
              const cfg = active.pie || {};
              const nameKey = cfg.nameKey || "name";
              const valueKey = cfg.valueKey || "value";
              const innerR = cfg.innerRadius ?? 0;
              const outerR = cfg.outerRadius ?? 90;
              const palette = buildPalette(data.length || 1, colors);
              return (
                <Pie
                  data={data}
                  dataKey={valueKey}
                  nameKey={nameKey}
                  innerRadius={innerR}
                  outerRadius={outerR}
                  cx="50%"
                  cy="50%"
                  label
                >
                  {data.map((_, i) => (
                    <Cell
                      key={`cell-${i}`}
                      fill={palette[i % palette.length]}
                    />
                  ))}
                </Pie>
              );
            })()}
          </PieChart>
        </ResponsiveContainer>
      )}

      {(sourceLabel || updatedFmt) && (
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            marginTop: -10,
            fontSize: 12,
            color: "#555",
            padding: "0 0px",
          }}
        >
          <div>{sourceLabel && <>Source: {sourceLabel}</>}</div>
          <div>{updatedFmt && <>Updated: {updatedFmt}</>}</div>
        </div>
      )}
    </div>
  );
}
