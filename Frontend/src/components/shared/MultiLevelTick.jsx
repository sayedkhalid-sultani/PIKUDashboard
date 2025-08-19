import React from "react";

/**
 * Multi-line tick for category axes (parent → … → leaf).
 * Works even when Recharts does not pass the full row in payload.payload.
 * Pass `rows` (data array) and `leafKey` so we can match the correct row.
 */
export default function MultiLevelTick({
  x,
  y,
  payload, // { value, index, ... }
  levels = [], // e.g. ["year","quarter","month"]
  leafKey, // last level key (the XAxis dataKey)
  rows = [], // full data array for lookup
  rotateIfTight = true,
  lineHeight = 22,
  fontSize = 12,
  estimatedCharPx = 7,
  containerWidth,
  itemCount,
  /** Extra top pad between axis line and first text line (px) */
  topPad = 4,
}) {
  // Find the row for this tick
  const idx = typeof payload?.index === "number" ? payload.index : -1;
  let row =
    (idx >= 0 && idx < rows.length && rows[idx]) ||
    (leafKey
      ? rows.find((r) => String(r?.[leafKey]) === String(payload?.value))
      : null) ||
    {};

  // Build the lines (fallback to axis value on leaf)
  const lines = (levels || []).map((k) =>
    k === leafKey
      ? String(row?.[k] ?? payload?.value ?? "")
      : String(row?.[k] ?? "")
  );

  // Simple width heuristic for rotation
  const combinedLen = lines.join(" ").length;
  let needsRotate = false;
  if (rotateIfTight) {
    if (containerWidth && itemCount) {
      const avgSlot = containerWidth / itemCount;
      const estLabelWidth = Math.max(1, combinedLen) * estimatedCharPx;
      needsRotate = estLabelWidth > avgSlot * 0.9;
    } else {
      needsRotate = combinedLen > 12 || lines.some((s) => s.length > 10);
    }
  }

  if (needsRotate) {
    return (
      <g transform={`translate(${x},${y})`}>
        {/* add topPad on rotated too */}
        <text
          textAnchor="end"
          transform="rotate(-90)"
          dy={4 + topPad}
          fontSize={fontSize}
        >
          {lines.map((txt, i) => (
            <tspan key={i} x="0" dy={i === 0 ? 0 : lineHeight}>
              {txt}
            </tspan>
          ))}
        </text>
      </g>
    );
  }

  // NON-rotated: give a little breathing room above the axis line
  return (
    <g transform={`translate(${x},${y})`}>
      <text textAnchor="middle" dy={14 + topPad} fontSize={fontSize}>
        {lines.map((txt, i) => (
          <tspan key={i} x="0" dy={i === 0 ? 0 : lineHeight}>
            {txt}
          </tspan>
        ))}
      </text>
    </g>
  );
}

/** Compute XAxis height (bottom pad = pad) */
MultiLevelTick.axisHeight = (count, lineHeight = 14, pad = 18) =>
  Math.max(28, pad + count * lineHeight);
